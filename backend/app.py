from flask import Flask, request, jsonify
from flask_cors import CORS
from db import get_db_connection

app = Flask(__name__)
CORS(app) # Enables frontend cross-origin access

# 0. AUTHENTICATION: Register or Login User
@app.route('/api/register_or_login', methods=['POST'])
def register_or_login():
    data = request.json or {}
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({"status": "error", "message": "Email and password are required"}), 400

    conn = get_db_connection()
    cur = conn.cursor()

    try:
        # Check if user already exists
        cur.execute("SELECT id, email, password FROM users WHERE email = %s;", (email,))
        user = cur.fetchone()

        if user:
            # User exists: Authenticate password
            # Note: Replace user[2] check with password hashing (e.g., bcrypt) in production
            if user[2] == password:
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
            # User does not exist: Register new user
            cur.execute(
                "INSERT INTO users (email, password) VALUES (%s, %s) RETURNING id, email;",
                (email, password)
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
        return jsonify({"status": "error", "message": str(e)}), 500

# 1. SECRETARY: Create Announcement & Add New Member
@app.route('/announcements', methods=['POST'])
def add_announcement():
    data = request.json
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO announcements (title, content, created_by) VALUES (%s, %s, %s) RETURNING *;",
        (data['title'], data['content'], data['secretary_id'])
    )
    new_announcement = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"status": "success", "data": new_announcement}), 201

# 2. TREASURER: Log Financial Transactions (Buys/Sells/Dues)
@app.route('/transactions', methods=['POST'])
def record_transaction():
    data = request.json
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        """INSERT INTO transactions (farmer_id, sheep_tag, type, amount, description, recorded_by)
           VALUES (%s, %s, %s, %s, %s, %s) RETURNING *;""",
        (data.get('farmer_id'), data.get('sheep_tag'), data['type'], data['amount'], data['description'], data['treasurer_id'])
    )
    tx = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"status": "success", "transaction": tx}), 201

# 3. SHEEP: Add Sheep (With Mother Link or Purchase Details)
@app.route('/sheep', methods=['POST'])
def add_sheep():
    data = request.json
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        """INSERT INTO sheep (tag_number, owner_id, mother_tag_number, breed, age_months, weight_kg, gender, feed_type, image_url)
           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s) RETURNING *;""",
        (data['tag_number'], data['owner_id'], data.get('mother_tag_number'), data['breed'], 
         data['age_months'], data['weight_kg'], data['gender'], data['feed_type'], data.get('image_url'))
    )
    
    # If sheep was purchased, record expense automatically
    if data.get('purchase_price'):
        cur.execute(
            """INSERT INTO transactions (farmer_id, sheep_tag, type, amount, description, recorded_by)
               VALUES (%s, %s, 'Expense', %s, %s, %s);""",
            (data['owner_id'], data['tag_number'], data['purchase_price'], f"Purchased sheep tag {data['tag_number']}", data['owner_id'])
        )

    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"status": "success", "message": "Sheep registered successfully"}), 201

# 4. VET: Record Treatment
@app.route('/treatments', methods=['POST'])
def record_treatment():
    data = request.json
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        """INSERT INTO treatment_logs (sheep_tag, vet_id, disease_diagnosed, medicine_administered, dosage)
           VALUES (%s, %s, %s, %s, %s) RETURNING *;""",
        (data['sheep_tag'], data['vet_id'], data['disease_diagnosed'], data['medicine_administered'], data.get('dosage'))
    )
    log = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"status": "success", "log": log}), 201

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)