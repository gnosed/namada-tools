from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
import subprocess
import shlex
import glob
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

@app.route('/ibc_shielded_memo', methods=['GET'])  # Note: Updated the route to match your curl command
def execute_command():
    # Retrieve parameters from the user request
    token = request.args.get('token', 'naan')  # Default value is 'naan'
    amount = request.args.get('amount', '1')
    port_id = request.args.get('port_id', 'transfer')
    channel_id = request.args.get('channel_id', '')
    target = request.args.get('target', '')

    # Ensure mandatory parameters are provided
    if not target or not channel_id:
        return jsonify({"error": "Target and channel_id parameters are required"}), 400

    # Construct the command with user-provided parameters
    command_template = "namadac ibc-gen-shielded --output-folder-path . --token {} --amount {} --port-id {} --channel-id {} --target {}"
    command = command_template.format(shlex.quote(token), shlex.quote(amount), shlex.quote(port_id), shlex.quote(channel_id), shlex.quote(target))

    try:
        # Execute the command
        output = subprocess.check_output(command, shell=True).decode('utf-8')  # Manually decode the output
        print(command)
        print(output)
        # Find the most recently created '.memo' file
        list_of_files = glob.glob('./*.memo')  # Assumes files are in the current directory
        latest_file = max(list_of_files, key=os.path.getctime)
        # Read and return the content of the file
        with open(latest_file, 'r') as file:
            file_content = file.read()
        return jsonify({"success": True, "memo": file_content})
    except subprocess.CalledProcessError as e:
        return jsonify({"success": False, "error": "Command execution failed: " + str(e)}), 500
    except Exception as e:
        return jsonify({"success": False, "error": "Failed to read the file content: " + str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
