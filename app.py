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


@app.route('/namespaces', methods=['GET'])
def get_namespace():

    config.load_kube_config()

    v1 = client.CoreV1Api()

    namespace = v1.list_namespace()

    for ns in namespace.items:

        return jsonify(ns.metadata.name)


@app.route('/pods/<ns_name>', methods=['GET'])
def get_pods_all_ns(ns_name):

    config.load_kube_config()

    v1 = client.CoreV1Api()

    pods = v1.list_namespaced_pod(ns_name)

    for pod in pods.items:

        return jsonify(pod.metadata.name)


if __name__ == '__main__':

    app.run()