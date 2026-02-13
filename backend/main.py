from firebase_functions import firestore_fn, https_fn, pubsub_fn, options
from firebase_admin import initialize_app, firestore
import datetime

initialize_app()
db = firestore.client()

# 1. On User Created: Referral Logic
@firestore_fn.on_document_created(document="users/{userId}")
def on_user_created(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    if event.data is None:
        return
        
    user_data = event.data.to_dict()
    referrer_id = user_data.get("referredBy")
    
    if referrer_id:
        referrer_ref = db.collection("users").document(referrer_id)
        
        @firestore.transactional
        def award_points(transaction, ref):
            snapshot = ref.get(transaction=transaction)
            if not snapshot.exists:
                return
            
            current_points = snapshot.get("totalPoints") or 0
            current_weekly = snapshot.get("weeklyPoints") or 0
            
            transaction.update(ref, {
                "totalPoints": current_points + 50,
                "weeklyPoints": current_weekly + 50
            })
            
        award_points(db.transaction(), referrer_ref)
        
        # Send notification
        db.collection("notifications").add({
            "toUserId": referrer_id,
            "type": "referral",
            "title": "New Crew Member! 🚀",
            "body": f"{user_data.get('nickname', 'Someone')} used your invite code! (+50 XP)",
            "timestamp": firestore.SERVER_TIMESTAMP,
            "status": "unread"
        })

# 2. On Message Created: Points & Notifications
@firestore_fn.on_document_created(document="teams/{teamId}/messages/{messageId}")
def on_message_created(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    if event.data is None:
        return

    message = event.data.to_dict()
    team_id = event.params["teamId"]
    sender_id = message.get("senderId")
    
    if sender_id:
        sender_ref = db.collection("users").document(sender_id)
        sender_ref.update({
            "totalPoints": firestore.Increment(2),
            "weeklyPoints": firestore.Increment(2),
            "lastActive": firestore.SERVER_TIMESTAMP
        })
        
        # Note: Notification logic to other members would go here (omitted for brevity)

# 3. Scheduled: Weekly Leaderboard Reset (Sunday Midnight)
@pubsub_fn.on_schedule(schedule="0 0 * * 0", timezone="America/Los_Angeles")
def weekly_reset(event: pubsub_fn.ScheduledEvent) -> None:
    batch = db.batch()
    users_ref = db.collection("users")
    
    # Simple implementation - typically requires pagination for large datasets
    docs = users_ref.stream()
    
    for doc in docs:
        batch.update(doc.reference, {"weeklyPoints": 0})
        
    batch.commit()
    print("Weekly leaderboard reset.")

# 4. Scheduled: Check Time Capsules (Every 15 mins)
@pubsub_fn.on_schedule(schedule="every 15 minutes")
def check_time_capsules(event: pubsub_fn.ScheduledEvent) -> None:
    now = datetime.datetime.now(datetime.timezone.utc)
    
    capsules = db.collection("timeCapsules")\
        .where(filter=firestore.FieldFilter("isUnlocked", "==", False))\
        .where(filter=firestore.FieldFilter("unlockDate", "<=", now))\
        .get()
        
    if not capsules:
        return

    batch = db.batch()
    
    for doc in capsules:
        data = doc.to_dict()
        batch.update(doc.reference, {"isUnlocked": True})
        
        for uid in data.get("contributors", []):
            user_ref = db.collection("users").document(uid)
            batch.update(user_ref, {
                "totalPoints": firestore.Increment(15),
                "weeklyPoints": firestore.Increment(15)
            })
            
            db.collection("notifications").add({
                "toUserId": uid,
                "type": "capsule_unlocked",
                "title": "Time Capsule Unlocked! ⏳🔓",
                "body": f"The '{data.get('title')}' capsule is now open!",
                "relatedId": doc.id,
                "timestamp": firestore.SERVER_TIMESTAMP,
                "status": "unread"
            })
            
    batch.commit()
    print(f"Unlocked {len(capsules)} time capsules.")
