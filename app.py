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

    pods_data = []

    ret = v1.list_pod_for_all_namespaces(namespace=ns_name, watch=False)

    for i in ret.items:
        pod_info = {
            "namespace": i.metadata.namespace,
            "name": i.metadata.name,
            "pod_ip": i.status.pod_ip
        }

        pods_data.append(pod_info)

    return jsonify(pods_data)



if __name__ == '__main__':

    app.run()