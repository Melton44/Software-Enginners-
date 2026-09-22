from flask import Flask, request, jsonify
from flask_cors import CORS
from functools import wraps
import bcrypt
import os
from dotenv import load_dotenv
from db import get_db_connection

# Load environment variables
load_dotenv()

app = Flask(__name__)

# Configure CORS with specific allowed origins
allowed_origins = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000").split(",")
CORS(app, origins=allowed_origins)

# Set secret key for session management
app.secret_key = os.getenv("FLASK_SECRET_KEY", "change-this-in-production")

# Authentication decorator
def require_auth(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return jsonify({"status": "error", "message": "Missing or invalid authorization header"}), 401
        
        # Extract and verify token (implement proper JWT verification in production)
        token = auth_header.split(" ")[1]
        # TODO: Implement proper JWT token verification here
        # For now, we'll extract user_id from the token (in production, use JWT decoding)
        try:
            user_id = int(token)  # Simple token format for demo
        except ValueError:
            return jsonify({"status": "error", "message": "Invalid token format"}), 401
        
        # Add user_id to request context
        request.user_id = user_id
        return f(*args, **kwargs)
    return decorated_function


# Helper function to hash password
def hash_password(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

# Helper function to verify password
def verify_password(password, hashed):
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

# 0. AUTHENTICATION: Register or Login User
@app.route('/api/register_or_login', methods=['POST'])
def register_or_login():
    data = request.json or {}
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({"status": "error", "message": "Email and password are required"}), 400
    
    # Input validation
    if len(password) < 6:
        return jsonify({"status": "error", "message": "Password must be at least 6 characters"}), 400

    conn = get_db_connection()
    cur = conn.cursor()

    try:
        # Check if user already exists
        cur.execute("SELECT id, email, password FROM users WHERE email = %s;", (email,))
        user = cur.fetchone()

        if user:
            # User exists: Authenticate password
            stored_password = user[2]
            # Verify password using bcrypt
            if verify_password(password, stored_password):
                cur.close()
                conn.close()
                return jsonify({
                    "status": "success", 
                    "message": "Logged in successfully",
                    "user_id": user[0]
                }), 200
            else:
                cur.close()
                conn.close()
                return jsonify({"status": "error", "message": "Invalid credentials"}), 401
        else:
            # User does not exist: Register new user with hashed password
            hashed_password = hash_password(password)
            cur.execute(
                "INSERT INTO users (email, password) VALUES (%s, %s) RETURNING id, email;",
                (email, hashed_password)
            )
            new_user = cur.fetchone()
            conn.commit()
            cur.close()
            conn.close()
            return jsonify({
                "status": "success", 
                "message": "User registered successfully",
                "user_id": new_user[0]
            }), 201

    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        # Log error internally but don't expose details to client
        app.logger.error(f"Registration/login error: {str(e)}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500

# 1. SECRETARY: Create Announcement (Protected)
@app.route('/announcements', methods=['POST'])
@require_auth
def add_announcement():
    data = request.json
    if not data:
        return jsonify({"status": "error", "message": "No data provided"}), 400
    
    # Validate required fields
    required_fields = ['title', 'content']
    for field in required_fields:
        if field not in data or not data[field]:
            return jsonify({"status": "error", "message": f"Missing required field: {field}"}), 400
    
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "INSERT INTO announcements (title, content, created_by) VALUES (%s, %s, %s) RETURNING *;",
            (data['title'], data['content'], request.user_id)
        )
        new_announcement = cur.fetchone()
        conn.commit()
        return jsonify({"status": "success", "data": new_announcement}), 201
    except Exception as e:
        conn.rollback()
        app.logger.error(f"Announcement error: {str(e)}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500
    finally:
        cur.close()
        conn.close()

# 2. TREASURER: Log Financial Transactions (Protected)
@app.route('/transactions', methods=['POST'])
@require_auth
def record_transaction():
    data = request.json
    if not data:
        return jsonify({"status": "error", "message": "No data provided"}), 400
    
    # Validate required fields
    required_fields = ['type', 'amount']
    for field in required_fields:
        if field not in data or not data[field]:
            return jsonify({"status": "error", "message": f"Missing required field: {field}"}), 400
    
    # Validate amount is a positive number
    try:
        amount = float(data['amount'])
        if amount <= 0:
            return jsonify({"status": "error", "message": "Amount must be positive"}), 400
    except (ValueError, TypeError):
        return jsonify({"status": "error", "message": "Invalid amount format"}), 400
    
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            """INSERT INTO transactions (farmer_id, sheep_tag, type, amount, description, recorded_by)
               VALUES (%s, %s, %s, %s, %s, %s) RETURNING *;""",
            (data.get('farmer_id'), data.get('sheep_tag'), data['type'], amount, 
             data.get('description', ''), request.user_id)
        )
        tx = cur.fetchone()
        conn.commit()
        return jsonify({"status": "success", "transaction": tx}), 201
    except Exception as e:
        conn.rollback()
        app.logger.error(f"Transaction error: {str(e)}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500
    finally:
        cur.close()
        conn.close()

# 3. SHEEP: Add Sheep (Protected)
@app.route('/sheep', methods=['POST'])
@require_auth
def add_sheep():
    data = request.json
    if not data:
        return jsonify({"status": "error", "message": "No data provided"}), 400
    
    # Validate required fields
    required_fields = ['tag_number', 'owner_id', 'breed', 'gender']
    for field in required_fields:
        if field not in data or not data[field]:
            return jsonify({"status": "error", "message": f"Missing required field: {field}"}), 400
    
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            """INSERT INTO sheep (tag_number, owner_id, mother_tag_number, breed, age_months, weight_kg, gender, feed_type, image_url)
               VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s) RETURNING *;""",
            (data['tag_number'], data['owner_id'], data.get('mother_tag_number'), data['breed'], 
             data.get('age_months'), data.get('weight_kg'), data['gender'], data.get('feed_type'), data.get('image_url'))
        )
        
        # If sheep was purchased, record expense automatically
        if data.get('purchase_price'):
            try:
                purchase_price = float(data['purchase_price'])
                if purchase_price > 0:
                    cur.execute(
                        """INSERT INTO transactions (farmer_id, sheep_tag, type, amount, description, recorded_by)
                           VALUES (%s, %s, 'Expense', %s, %s, %s);""",
                        (data['owner_id'], data['tag_number'], purchase_price, 
                         f"Purchased sheep tag {data['tag_number']}", request.user_id)
                    )
            except (ValueError, TypeError):
                app.logger.warning(f"Invalid purchase_price: {data.get('purchase_price')}")
        
        conn.commit()
        return jsonify({"status": "success", "message": "Sheep registered successfully"}), 201
    except Exception as e:
        conn.rollback()
        app.logger.error(f"Sheep registration error: {str(e)}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500
    finally:
        cur.close()
        conn.close()

# 4. VET: Record Treatment (Protected)
@app.route('/treatments', methods=['POST'])
@require_auth
def record_treatment():
    data = request.json
    if not data:
        return jsonify({"status": "error", "message": "No data provided"}), 400
    
    # Validate required fields
    required_fields = ['sheep_tag', 'disease_diagnosed', 'medicine_administered']
    for field in required_fields:
        if field not in data or not data[field]:
            return jsonify({"status": "error", "message": f"Missing required field: {field}"}), 400
    
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            """INSERT INTO treatment_logs (sheep_tag, vet_id, disease_diagnosed, medicine_administered, dosage)
               VALUES (%s, %s, %s, %s, %s) RETURNING *;""",
            (data['sheep_tag'], request.user_id, data['disease_diagnosed'], 
             data['medicine_administered'], data.get('dosage'))
        )
        log = cur.fetchone()
        conn.commit()
        return jsonify({"status": "success", "log": log}), 201
    except Exception as e:
        conn.rollback()
        app.logger.error(f"Treatment logging error: {str(e)}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    debug_mode = os.getenv("FLASK_DEBUG", "False").lower() in ("true", "1", "yes")
    app.run(debug=debug_mode, host='0.0.0.0', port=5000)