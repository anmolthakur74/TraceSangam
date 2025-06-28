from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash

from models import db, User  # ✅ Import your model correctly

app = Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'  # ✅ this creates it in the same folder as app.py
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# ✅ Bind Flask app to SQLAlchemy
db.init_app(app)

# ✅ Create DB inside app context
with app.app_context():
    db.create_all()

@app.route('/api/signup', methods=['POST'])
def signup():
    data = request.get_json()

    if not data.get('email') or not data.get('password'):
        return jsonify({'message': 'Email and password required'}), 400

    existing_user = User.query.filter_by(email=data['email']).first()
    if existing_user:
        return jsonify({'message': 'User already exists'}), 400

    hashed_pw = generate_password_hash(data['password'], method='sha256')
    new_user = User(email=data['email'], password=hashed_pw)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({'message': 'User created successfully'}), 201


@app.route('/frontend/login', methods=['POST'])
def login():
    data = request.get_json()
    user = User.query.filter_by(email=data['email']).first()

    if user and check_password_hash(user.password, data['password']):
        return jsonify({'message': 'Login successful', 'email': user.email}), 200
    return jsonify({'message': 'Invalid credentials'}), 401

if __name__ == '__main__':
    app.run(debug=True)
