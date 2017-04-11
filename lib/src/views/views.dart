import 'dart:io';
import 'package:angel_common/angel_common.dart';
import 'package:html_builder/elements.dart';
import 'package:html_builder/html_builder.dart';
import '../models/note.dart';
import '../models/user.dart';

final StringRenderer RENDERER = new StringRenderer(pretty: false);

configureServer(Angel app) async {
  final noteService = app.service('api/notes');

  app.get('/', indexPage(noteService));
}

RequestHandler indexPage(Service noteService) {
  return (RequestContext req, ResponseContext res) async {
    List<Note> notes = [];
    Node list;

    if (req.properties.containsKey('user')) {
      var user = req.user as User;
      notes.addAll(await noteService.index({
        'query': {'userId': user.id}
      }));
    }

    if (notes.isEmpty) {
      list =
          div(className: 'ui message', children: [text('You have no notes.')]);
    } else {
      list = ul(children: notes.map((note) => li(children: [text(note.text)])));
    }

    await renderNode(
        layout('Notes', req, [
          a(
              className: 'ui teal button',
              href: '/notes/new',
              style: {'float': 'right'},
              children: [i(className: 'ui plus icon'), text('Add')]),
          h1(
              className: 'ui header',
              children: [text('Notes (${notes.length})')]),
          list
        ]),
        res);
  };
}

renderNode(Node node, ResponseContext res) async {
  res
    ..contentType = ContentType.HTML
    ..write(RENDERER.render(node))
    ..end();
}

Node layout(String pageTitle, RequestContext req, Iterable<Node> content) {
  return html(children: [
    head(children: [
      title(children: [text(pageTitle)]),
      meta(name: 'viewport', content: 'width=device-width, initial-scale=1'),
      link(
          rel: 'stylesheet',
          href:
          'https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.10/semantic.min.css')
    ]),
    body(children: [
      mainMenu(req),
      div(className: ['ui', 'container'], children: content),
      script(src: 'https://code.jquery.com/jquery-3.2.1.min.js',
          type: 'text/javascript'),
      script(
          src: 'https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.10/semantic.min.js',
          type: 'text/javascript'),
      script(type: 'text/javascript', children: [text(JS_SCRIPT)])
    ])
  ]);
}

Node mainMenu(RequestContext req) {
  Node rightMenu;

  if (!req.properties.containsKey('user')) {
    rightMenu = div(className: 'right menu', children: [
      div(className: 'ui item', children: [
        a(href: '/auth/google', className: 'ui inverted button', children: [
          i(className: 'ui google plus icon'),
          text('Sign in with Google')
        ])
      ])
    ]);
  } else {
    var user = req.user as User;
    rightMenu = div(className: 'right menu', children: [
      div(className: 'ui dropdown item', children: [
        i(className: 'user icon'),
        text(user.name),
        i(className: 'dropdown icon'),
        div(className: 'menu', children: [
          a(
              className: 'item',
              href: '/auth/logout',
              children: [i(className: 'sign out icon'), text('Log out')])
        ])
      ])
    ]);
  }

  return div(className: 'ui inverted borderless teal menu', style: {
    'border-radius': 0
  }, children: [
    a(
        href: '/',
        className: 'ui header item',
        children: [i(className: 'book icon'), text('Notes')]),
    rightMenu
  ]);
}

const String JS_SCRIPT =
r'''
$(function() {
  $('.ui.dropdown').dropdown();
})
''';
