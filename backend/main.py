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
    # Award starting points to the new user
    user_ref = db.collection("users").document(event.params["userId"])
    user_ref.update({
        "totalPoints": firestore.Increment(200),
        "weeklyPoints": firestore.Increment(200),
        "lastActive": firestore.SERVER_TIMESTAMP
    })

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

# 5. Callable: Award Points for Client Actions (Polls, Games, etc.)
@https_fn.on_call()
def award_activity_points(req: https_fn.CallableRequest) -> dict:
    """
    Securely awards points for client-side activities.
    Requires authentication.
    """
    if not req.auth:
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.UNAUTHENTICATED, message="User must be logged in.")

    uid = req.auth.uid
    data = req.data
    activity_type = data.get("type")
    
    # Point values
    POINTS_MAP = {
        "poll_vote": 2,
        "mini_game_win": 15,
        "daily_prompt": 5,
        "capsule_create": 10,
        "streak_7_day": 25
    }
    
    points = POINTS_MAP.get(activity_type)
    if not points:
         raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT, message="Invalid activity type.")

    user_ref = db.collection("users").document(uid)
    
    user_ref.update({
        "totalPoints": firestore.Increment(points),
        "weeklyPoints": firestore.Increment(points),
        "lastActive": firestore.SERVER_TIMESTAMP
    })
    
    return {"success": True, "points_awarded": points}

# HTTP Callable: Initialize Points for All Users
@https_fn.on_call()
def initialize_all_user_points(req: https_fn.CallableRequest) -> dict:
    """
    One-time function to add weeklyPoints and totalPoints to all existing users
    who don't have these fields yet.
    """
    try:
        users_ref = db.collection('users')
        users = users_ref.stream()
        
        updated_count = 0
        skipped_count = 0
        
        for user in users:
            user_data = user.to_dict()
            user_id = user.id
            
            # Check if points fields are missing
            needs_update = {}
            
            if 'weeklyPoints' not in user_data:
                needs_update['weeklyPoints'] = 0
                
            if 'totalPoints' not in user_data:
                needs_update['totalPoints'] = 200  # Starting bonus
            
            if needs_update:
                users_ref.document(user_id).update(needs_update)
                updated_count += 1
                print(f"✅ Updated user {user_id}: {needs_update}")
            else:
                skipped_count += 1
        
        return {
            "success": True,
            "message": f"Initialized points for {updated_count} users (skipped {skipped_count} users who already had points)",
            "updated": updated_count,
            "skipped": skipped_count
        }
        
    except Exception as e:
        print(f"Error initializing points: {e}")
        return {
            "success": False,
            "error": str(e)
        }
