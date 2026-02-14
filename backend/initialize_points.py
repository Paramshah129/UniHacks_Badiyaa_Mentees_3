import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin (if not already initialized)
try:
    firebase_admin.get_app()
except ValueError:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

def initialize_user_points():
    """Add weeklyPoints and totalPoints to all users who don't have them"""
    users_ref = db.collection('users')
    users = users_ref.stream()
    
    count = 0
    for user in users:
        user_data = user.to_dict()
        user_id = user.id
        
        # Check if points fields are missing
        needs_update = False
        update_data = {}
        
        if 'weeklyPoints' not in user_data:
            update_data['weeklyPoints'] = 0
            needs_update = True
            
        if 'totalPoints' not in user_data:
            update_data['totalPoints'] = 0
            needs_update = True
        
        if needs_update:
            users_ref.document(user_id).update(update_data)
            count += 1
            print(f"✅ Updated user {user_id}: {update_data}")
    
    print(f"\n🎉 Successfully initialized points for {count} users!")

if __name__ == "__main__":
    initialize_user_points()
