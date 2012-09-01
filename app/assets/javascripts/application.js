// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Pusher notifications

$(document).ready(function() {
	// Update notification and message count in title bar
	var notification_count = parseInt($('#notification-count').html());
	var message_count = parseInt($('#message-count').html());
	
	var count = notification_count + message_count;
	
	if (count > 0) {
		document.title = "Simplifeed (" + count + ")";
	}
	
	// Pusher api key
	var pusher = new Pusher('6a893338845f2e5a617a');
	var channel = pusher.subscribe('simplifeed');
	
	// Pusher event for notifications
	if (typeof(notification_event_id) !== 'undefined') {
		channel.bind(notification_event_id, function(data) {
			if (data.message) {
				var notification_count = parseInt($('#notification-count').html());
				var message_count = parseInt($('#message-count').html());
				
				var count = notification_count + message_count;
				
				count++;
				
				if (count > 0) {
					document.title = "Simplifeed (" + count + ")";
				}
				
				notification_count++;
				$('#notification-count').html(notification_count);
				$('#notifications .empty').remove();
				$('#notifications').append(data.message);
				$('#notification-count').addClass('badge-info');
				
				var alert_id = 'alert-' + Math.floor(Math.random()*9999999);
				
				var html = '<div id="' + alert_id + '" class="span12 alert alert-info">';
			    html += '<a class="close" data-dismiss="alert" href="#">×</a>';
			    html += '<p>'
				html += '<span class="text">' + data.message + '</span></p></div>';
	
				$('#growl-notifications').append(html);
				
				document.title = "Simplifeed (" + count + ")";
				
				var timeout = window.setTimeout(function() {
				    $('#' + alert_id).fadeOut();
				}, 6000);
			}
		});
	}
	
	// Pusher event for messages
	if (typeof(message_event_id) !== 'undefined')  {
		channel.bind(message_event_id, function(data) {
			if (data.message) {	
				var notification_count = parseInt($('#notification-count').html());
				var message_count = parseInt($('#message-count').html());
				
				var count = notification_count + message_count;
				
				count++;
				
				if (count > 0) {
					document.title = "Simplifeed (" + count + ")";
				}
				
				message_count++;
				
				$('#message-count').html(message_count);
				
				count = parseInt($('a[data-target=#chat-' + data.friend + ']').find('.unread-count').html());
				count++;
				$('a[data-target=#chat-' + data.friend + ']').find('.unread-count').html(count);
				
				
				
				var chat_feed = $('#chat-' + data.friend + ' .chat-feed');
				
				var message = '<p>' + data.friend_username + ': ' + data.message + '<span class="pull-right">' + data.time + '</span></p>';
				
				chat_feed.append(message);
	
				$(chat_feed).scrollTop($(chat_feed).height());
				
				$('a[data-target=#chat-' + data.friend + ']').find('.unread-count').removeClass('badge-info').addClass('badge-info');
				
				$('#message-count').removeClass('badge-info').addClass('badge-info');
			}
		});
	}
	
	// Make Enter/Return send message in chat
	$('.chat-input').keypress(function(e){
	  if(e.keyCode == 13 && !e.shiftKey) {
	   e.preventDefault();
	   $(this).closest(".chat-window").find('.chat-send').click();
	  }
	});
	
	$('.collapse').on('shown', function () {
  		$(this).addClass('overflowing');
  		$(this).find('.collapse').addClass('overflowing');
  	});
  	
  	$('.collapse').on('hide', function () {
	  	$(this).removeClass('overflowing');
	  	$(this).find('.collapse').removeClass('overflowing');
  	});
	
	// Open edit post modal
	$('.open-edit-post').on('click', function () {
	  var post_id = $(this).attr('post');
	  var content = $(this).closest('.post-item').find('.post-content').html();
	  $('#post_id').val(post_id);
	  $('#edit-post #body').val(content);
	});
	
	// Open comment modal
	$('.open-comment-post').on('click', function () {
	  var post_id = $(this).attr('post');
	  $('#reply_to').val(post_id);
	});
	
	// Open confirm delete post modal
	$('.open-confirm-delete').on('click', function () {
	  var post_id = $(this).attr('post');
	  $('#confirm-delete-form').attr('action', '/posts/' + post_id);
	});
	
	// Initialize all chat windows as hidden modals without backdrop
	$('.chat-window').each(function(e){
		$(this).modal({backdrop:false, show:false});
	});
	
	// Mark all friend messages as read when focus is brought to chat input
	$('.chat-input').focus( function() {
		var id = $(this).attr('chat-id');
		postMessagesAsRead(id);
	});
	
	// Mark all friends messages as read when chat window is opened
	$('.toggle-chat').live('click', function() {
		var id = $(this).attr('data-target').split('-')[1];
		postMessagesAsRead(id);
	});
	
	// Send chat message on chat submit
	$('.chat-send').on('click', function() {
		var chat_window = $(this).closest('.chat-window');
		var chat_input = $(chat_window).find('.chat-input');
		var chat_id = $(chat_input).attr('chat-id');
		var username = $(chat_input).attr('chat-username');
		var message = $(chat_input).val();
		var message_row = '<p>' + username + ': ' + message + '<span class="pull-right">' + getFormattedTime() + '</span></p>';

		$.ajax({ url: '/send_message.json',
		  type: 'POST',
		  beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
		  data: { to: chat_id, message: message },
		  success: function(response) {
		    $(chat_window).find('.chat-feed').append(message_row);
		  	$(chat_input).val('');
		  }
		});

	});
	
	// Add error class to any form sections with an error in it
	$('.control-group').has('.field_with_errors').addClass('error');
	
	// Make all links to images open in fancy box
	$("a[href$='.jpg'],a[href$='.jpeg'],a[href$='.png'],a[href$='.gif']").attr('rel', 'gallery').fancybox();
	
	
	setInterval(updateChatList,25000);
});

var updateChatList = function() {
	$.getJSON('chat.json', function(data) {
		var online_count = data.online.length;
		$("#messages").html('');
		var friend_count = '';
		var friend_cell = '';
		if (data.recent.length > 0) {
		$.each(data.recent, function(i,friend){
			if (data.unread[friend.id] != null && parseInt(data.unread[friend.id]) > 0) {
				friend_count = '<span class="badge badge-info unread-count">' + data.unread[friend.id] + '</span> ';
			}
			else {
				friend_count = '<span class="badge unread-count">0</span> ';
			}
			if (($.inArray(friend.id, data.online)) >= 0) {
				friend_cell = '<li><a class="toggle-chat" data-toggle="modal" data-target="#chat-' + friend.id + '">' + friend_count + friend.username + ' <span class="label label-info">Online</span></a></li>';
			}
			else {
				friend_cell = '<li><a class="toggle-chat" data-toggle="modal" data-target="#chat-' + friend.id + '">' + friend_count + friend.username + '</a></li>';
			}
		    $("#messages").append(friend_cell);
		});
		}
		else {
			$("#messages").append('<li class="empty"><a href="#">Nothing to see here</a></li>');
		}
	});
};

function postMessagesAsRead(id) {
	$.ajax({ url: '/mark_as_read',
		  type: 'POST',
		  beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
		  data: { friend_id: id },
		  success: function(response) {
			  if (response.success) {
				  var count = parseInt($('#message-count').html());
				  
				  count = count - response.count;
				  $('#message-count').html(count);
				  
				  if (count <= 0) {
					  $('#message-count').removeClass('badge-info');
				  }
				  
				  var $friend_count = $('a[data-target=#chat-' + id + ']').find('.unread-count');
				  
				  count = parseInt($friend_count.html());
				  count = count - response.count;
				  $friend_count.html(count);
				  
				  if (count <= 0) {
					  $friend_count.removeClass('badge-info');
				  }
			  }
		  }
		});
}

function getFormattedTime() {
	var currentTime = new Date();
	var hours = currentTime.getHours();
	var minutes = currentTime.getMinutes();
	
	if (minutes < 10){
		minutes = "0" + minutes;
	}
	
	var formatted_hours = hours;
	
	if (hours > 12) {
		formatted_hours = hours - 12;
	}
	
	var formatted = formatted_hours + ":" + minutes + " ";
	
	if (hours > 11){
		formatted += "PM";
	} 
	else {
		formatted += "AM";
	}
	
	return formatted;
}

$(function () {
  $('.upload').fileUploadUI({
        uploadTable: $('.upload_files'),
        downloadTable: $('.download_files'),
        buildUploadRow: function (files, index) {
            var file = files[index];
            return $('<tr><td>' + file.name + '<\/td>' +
                    '<td class="file_upload_progress"><div><\/div><\/td>' +
                    '<td class="file_upload_cancel">' +
                    '<button class="ui-state-default ui-corner-all" title="Cancel">' +
                    '<span class="ui-icon ui-icon-cancel">Cancel<\/span>' +
                    '<\/button><\/td><\/tr>');
        },
        buildDownloadRow: function (file) {
            return $('<tr><td><img alt="Photo" width="40" height="40" src="' + file.pic_path + '">' + file.name + '<\/td><\/tr>');
        },
    });
});
/**
 * Timeago is a jQuery plugin that makes it easy to support automatically
 * updating fuzzy timestamps (e.g. "4 minutes ago" or "about 1 day ago").
 *
 * @name timeago
 * @version 0.11.3
 * @requires jQuery v1.2.3+
 * @author Ryan McGeary
 * @license MIT License - http://www.opensource.org/licenses/mit-license.php
 *
 * For usage and examples, visit:
 * http://timeago.yarp.com/
 *
 * Copyright (c) 2008-2012, Ryan McGeary (ryan -[at]- mcgeary [*dot*] org)
 */
 
 
jQuery(document).ready(function() {
  jQuery("abbr.timeago").timeago();
});
 
(function($) {
  $.timeago = function(timestamp) {
    if (timestamp instanceof Date) {
      return inWords(timestamp);
    } else if (typeof timestamp === "string") {
      return inWords($.timeago.parse(timestamp));
    } else if (typeof timestamp === "number") {
      return inWords(new Date(timestamp));
    } else {
      return inWords($.timeago.datetime(timestamp));
    }
  };
  var $t = $.timeago;

  $.extend($.timeago, {
    settings: {
      refreshMillis: 60000,
      allowFuture: false,
      strings: {
        prefixAgo: null,
        prefixFromNow: null,
        suffixAgo: "ago",
        suffixFromNow: "from now",
        seconds: "less than a minute",
        minute: "about a minute",
        minutes: "%d minutes",
        hour: "about an hour",
        hours: "about %d hours",
        day: "a day",
        days: "%d days",
        month: "about a month",
        months: "%d months",
        year: "about a year",
        years: "%d years",
        wordSeparator: " ",
        numbers: []
      }
    },
    inWords: function(distanceMillis) {
      var $l = this.settings.strings;
      var prefix = $l.prefixAgo;
      var suffix = $l.suffixAgo;
      if (this.settings.allowFuture) {
        if (distanceMillis < 0) {
          prefix = $l.prefixFromNow;
          suffix = $l.suffixFromNow;
        }
      }

      var seconds = Math.abs(distanceMillis) / 1000;
      var minutes = seconds / 60;
      var hours = minutes / 60;
      var days = hours / 24;
      var years = days / 365;

      function substitute(stringOrFunction, number) {
        var string = $.isFunction(stringOrFunction) ? stringOrFunction(number, distanceMillis) : stringOrFunction;
        var value = ($l.numbers && $l.numbers[number]) || number;
        return string.replace(/%d/i, value);
      }

      var words = seconds < 45 && substitute($l.seconds, Math.round(seconds)) ||
        seconds < 90 && substitute($l.minute, 1) ||
        minutes < 45 && substitute($l.minutes, Math.round(minutes)) ||
        minutes < 90 && substitute($l.hour, 1) ||
        hours < 24 && substitute($l.hours, Math.round(hours)) ||
        hours < 42 && substitute($l.day, 1) ||
        days < 30 && substitute($l.days, Math.round(days)) ||
        days < 45 && substitute($l.month, 1) ||
        days < 365 && substitute($l.months, Math.round(days / 30)) ||
        years < 1.5 && substitute($l.year, 1) ||
        substitute($l.years, Math.round(years));

      var separator = $l.wordSeparator === undefined ?  " " : $l.wordSeparator;
      return $.trim([prefix, words, suffix].join(separator));
    },
    parse: function(iso8601) {
      var s = $.trim(iso8601);
      s = s.replace(/\.\d\d\d+/,""); // remove milliseconds
      s = s.replace(/-/,"/").replace(/-/,"/");
      s = s.replace(/T/," ").replace(/Z/," UTC");
      s = s.replace(/([\+\-]\d\d)\:?(\d\d)/," $1$2"); // -04:00 -> -0400
      return new Date(s);
    },
    datetime: function(elem) {
      var iso8601 = $t.isTime(elem) ? $(elem).attr("datetime") : $(elem).attr("title");
      return $t.parse(iso8601);
    },
    isTime: function(elem) {
      // jQuery's `is()` doesn't play well with HTML5 in IE
      return $(elem).get(0).tagName.toLowerCase() === "time"; // $(elem).is("time");
    }
  });

  $.fn.timeago = function() {
    var self = this;
    self.each(refresh);

    var $s = $t.settings;
    if ($s.refreshMillis > 0) {
      setInterval(function() { self.each(refresh); }, $s.refreshMillis);
    }
    return self;
  };

  function refresh() {
    var data = prepareData(this);
    if (!isNaN(data.datetime)) {
      $(this).text(inWords(data.datetime));
    }
    return this;
  }

  function prepareData(element) {
    element = $(element);
    if (!element.data("timeago")) {
      element.data("timeago", { datetime: $t.datetime(element) });
      var text = $.trim(element.text());
      if (text.length > 0 && !($t.isTime(element) && element.attr("title"))) {
        element.attr("title", text);
      }
    }
    return element.data("timeago");
  }

  function inWords(date) {
    return $t.inWords(distance(date));
  }

  function distance(date) {
    return (new Date().getTime() - date.getTime());
  }

  // fix for IE6 suckage
  document.createElement("abbr");
  document.createElement("time");
}(jQuery));