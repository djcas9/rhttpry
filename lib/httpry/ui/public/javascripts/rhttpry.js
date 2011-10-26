var Event;
var Events;
var rhttpry;
var Stats;

Stats = {
  inbound: 0,
  outbound: 0,
  method: {},
  host: {},
  statusCode: {},
  source: {},
  destination: {}
};

////

Event = function() {
  
  function Event(event, order) {
    var self = this;
    self.raw = event;
    
    // Timestamp
    self.date = new Date(event.date);
    self.time = new Date(event.time);
    self.timestamp = new Date(event.timestamp);

    // Source & Destination 
    self.destination = event.dest_ip;
    self.source = event.source_ip;
    
    // HTTP Request
    self.host = event.host;
    self.status_code = event.status_code;
    self.method = event.method;
    self.http_version = event.http_version;
    self.uri = event.request_uri;
    self.url = self.host + self.uri;
    self.reason_phrase = event.reason_phrase;

    if (event.direction === ">") {
      self.direction = "outbound";
    } else if (event.direction === "<") {
      self.direction = "inbound";
    } else {
      self.direction = false;
    };

    self.order = order;

  };

  Event.prototype = {
  
    render: function() {
      var self = this;
      
      self.$event = $('<div class="event" />')
      .attr('data-source', self.source)
      .attr('data-destination', self.destination)
      .attr('data-direction', self.direction);

      self.$event.append(self.url);

      self.$event.clone()[self.order]('#all');

      if ($('#wrapper #hosts .watch[data-id="' + self.host + '"]')) {
        self.$event.clone()[self.order]('#wrapper #hosts .watch[data-id="' + self.host + '"]');
      };

      if ($('#wrapper #source_address .watch[data-id="' + self.source + '"]')) {
        self.$event.clone()[self.order]('#wrapper #source_address .watch[data-id="' + self.source + '"]');
      };

      if ($('#wrapper #destination_address .watch[data-id="' + self.destination + '"]')) {
        self.$event.clone()[self.order]('#wrapper #destination_address .watch[data-id="' + self.destination + '"]');
      };

      if (self.direction) {
        if (self.direction === "inbound") { self.addInbound() };
        if (self.direction === "outbound") { self.addOutbound() };
      };

      self.count();

      return self.$event;
    },

    addInbound: function() {
      var self = this;
      Stats.inbound++;
      //self.$event.clone()[self.order]('#inbound');
    },

    addOutbound: function() {
      var self = this;
      Stats.outbound++;

      //self.$event.clone()[self.order]('#outbound');
    },

    // Build Status
    count: function() {
      var self = this;
      
      self.add_count(Stats.method, self.method);
      self.add_count(Stats.host, self.host);
      self.add_count(Stats.statusCode, self.status_code);
      self.add_count(Stats.destination, self.destination);
      self.add_count(Stats.source, self.source);

    },

    add_count: function(key, value) {
      var self = this;

      if (key[value]) {
        key[value]++;
      } else {
        key[value] = 0;
        key[value]++;
      };

      return false;
    },

  };

  return Event;
}();

////

rhttpry = {
  
  content: [
    'dashboard',
    'inbound',
    'outbound',
    'host',
    'source_address',
    'destination_address'
  ],

  render: function() {
    var self = this;
    var content = self.content;

    for (var i = 0; i < content.length; i += 1) {
      $html = $('<div id="'+content[i]+'" />')
      .addClass('box')
      .hide();
      $('#wrapper').append($html);
    };

    return false;
  },

  ws: null,

  connect: function() {
    var self = this;
    var browser = jQuery.browser;

    if (browser.webkit || browser.opera) {

      self.ws = new WebSocket("ws://localhost:8080/");
      self.webSocketCallbacks();

    } else if (browser.mozilla) {

      self.ws = new MozWebSocket("ws://localhost:8080/");
      self.webSocketCallbacks();

    } else {
      alert('FAIL!');
    };
    
  },

  webSocketCallbacks: function() {
    var self = this;

    self.ws.onopen = function() {
      console.log("socket open");
    };

    self.ws.onmessage = function(evt) {       
      var data = JSON.parse(evt.data);

      if (data.type === "event") {
       self.loadEvent(data.data, 'prependTo'); 
      } else if (data.type == "ping") {
        //console.log('PING');
        //self.ws.send('PONG')
      } else {
        console.log(data)
      };

    };

    self.ws.onclose = function() { 
      console.log("socket closed"); 
    };

  },

  events: [],
  
  loadEvent: function(event, order) {
    var self = this;
    
    var obj = new Event(event, order);
    rhttpry.events.push(obj);

    obj.render();

    return obj;
  },

  loadEvents: function(events, order) {
    var self = this;

    for (var i = 0; i < events.length; i += 1) {
      self.loadEvent(events[i], order);
    };
    
    return events;
  }

};

////

jQuery(document).ready(function($) {

  rhttpry.render()
  rhttpry.connect();

});




