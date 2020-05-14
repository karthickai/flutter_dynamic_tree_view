import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_treeview/tree_view.dart';

const String admin = "http://www.mocky.io/v2/5ebdc23f3100005f00c5cd3f";
const String supervisor = "http://www.mocky.io/v2/5ebdc37a3100008f00c5cd42";
const String operator = "http://www.mocky.io/v2/5ebdc5a13100008f00c5cd48";

Future<List<Node>> getSection(String data) async {
  String url;
  if(data == "admin"){
    url = admin;
  }else if(data == "supervisor"){
    url = supervisor;

  }else if(data == "operator"){
    url = operator;
  }
  final response = await http.get(url);

  if (response.statusCode == 200) {

    return generateNode(json.decode(response.body));
  } else {

    throw Exception('Failed to load album');
  }
}

List<Node> generateNode(List<dynamic> json){
  List<Node> _nodes = List<Node>();
  _nodes = [];
  for(var node in json){
    Node _localNode = createNode(node);
    if(_localNode != null){
      _nodes.add(createNode(node));

    }
  }
return _nodes;
}

Node createNode(Map<String, dynamic> node){
  Node _node;
  if(node["children"].length == 0){
    _node = Node(
        label: node["label"],
        key: node["label"],
        expanded: true,
        icon: NodeIcon(
          codePoint: Icons.insert_drive_file.codePoint,
          color: "blue",
        )
    );
    return _node;
  }else {
    List<Node> _childNodes = List<Node>();

    for(var i = 0; i < node["children"].length; i++){
      Node _localNode = createNode(node["children"][i]);
      if(_localNode != null){
        _childNodes.add(_localNode);

      }
    }
    _node = Node(
        label: node["label"],
        key: node["label"],
        expanded: true,
        icon: NodeIcon(
          codePoint: Icons.folder_open.codePoint,
          color: "blue",
        ),
        children: _childNodes,
    );
    return _node;

  }

}