# app.py
from flask import Flask, jsonify
import logging
import time
import threading
import os
import json

app = Flask(__name__)

# Configurer le logging
logging.basicConfig(filename='app.log', level=logging.INFO, format='%(asctime)s: %(message)s')

logs = []

def log_reader():
    """ Fonction pour lire en continu un fichier de log et mettre à jour la liste des logs. """
    log_file_path = 'app.log'
    if not os.path.exists(log_file_path):
        open(log_file_path, 'a').close()  # Créer le fichier s'il n'existe pas

    while True:
        with open(log_file_path, 'r') as f:
            lines = f.readlines()
            # Ajouter uniquement les nouvelles lignes aux logs
            for line in lines:
                if line not in logs:
                    logs.append(line.strip())
        
        time.sleep(5)  # Attendre 5 secondes avant de relire

@app.route('/')
def home():
    return jsonify({"message": "Welcome to the custom web server!"})

@app.route('/log')
def log_event():
    log_message = "Log event occurred!"
    logging.info(log_message)
    return jsonify({"status": "Logged", "message": log_message})

@app.route('/logs', methods=['GET'])
def get_logs():
    return jsonify({"logs": logs})

if __name__ == '__main__':
    # Lancer le thread pour lire les logs
    log_thread = threading.Thread(target=log_reader, daemon=True)
    log_thread.start()
    
    app.run(host='0.0.0.0', port=80)
