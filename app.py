from flask import Flask, jsonify, request
from kubernetes import client, config

app = Flask(__name__)


@app.route('/nodes', methods=['GET'])
def get_nodes():

    config.load_kube_config()

    v1 = client.CoreV1Api()

    nodes = v1.list_node().items

    for node in nodes:

        return jsonify(node.metadata.name)


if __name__ == '__main__':

    app.run()