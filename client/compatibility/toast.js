//
// Toast popup notifier
//
// By: Stuart Rackham
// https://github.com/srackham/toast.js
//
// Inspired by: https://github.com/Srirangan/notifer.js
//              https://github.com/CodeSeven/toastr
//
/// <reference path="jquery.d.ts" />
var Toast;
(function (Toast) {
    // Modifiable defaults.
    Toast.defaults = {
        width: '',
        displayDuration: 2000,
        fadeOutDuration: 800
    };
    Toast.showing = false;
    /* Popup functions */
    /**
     * Popup informational message.
     * @param message A message string.
     * @param title An optional title string.
     * @param options An optional map of {@link Options}.
     */
    function info(message, title, options) {
        _toast('info', message, title, options);
    }
    Toast.info = info;
    /**
     * Popup warning message.
     * @param message A message string.
     * @param title An optional title string.
     * @param options An optional map of {@link Options}.
     */
    function warning(message, title, options) {
        _toast('warning', message, title, options);
    }
    Toast.warning = warning;
    /**
     * Popup error message.
     * @param message A message string.
     * @param title An optional title string.
     * @param options An optional map of {@link Options}.
     */
    function error(message, title, options) {
        _toast('error', message, title, options);
    }
    Toast.error = error;
    /**
     * Popup success message.
     * @param message A message string.
     * @param title An optional title string.
     * @param options An optional map of {@link Options}.
     */
    function success(message, title, options) {
        _toast('success', message, title, options);
    }
    Toast.success = success;
    /* Private variables and functions */
    var _container; // Toast container DOM element.
    function _toast(type, // 'info', 'success', 'error', 'warning'
        message, title, options) {
        if (options === void 0) { options = {}; }
        options = $.extend({}, Toast.defaults, options);
        if (!_container) {
            _container = $('#toast-container');
            if (_container.length === 0) {
                // Create container element if it is not in the static HTML.
                _container = $('<div>').attr('id', 'toast-container').appendTo($('body'));
            }
        }
        if (options.width) {
            _container.css({ width: options.width });
        }
        var toastElement = $('<div>').addClass('toast').addClass('toast-' + type);
        if (title) {
            var titleElement = $('<div>').addClass('toast-title').append(title);
            toastElement.append(titleElement);
        }
        if (message) {
            var messageElement = $('<div>').addClass('toast-message').append(message);
            toastElement.append(messageElement);
        }
        if (options.displayDuration > 0) {
            setTimeout(function () {
                toastElement.fadeOut(options.fadeOutDuration, function () {
                    Toast.showing = false
                    toastElement.remove();
                });
            }, options.displayDuration);
        }
        toastElement.on('click', function () {
            Toast.showing = false
            toastElement.remove();
        });
        Toast.showing = true
        _container.prepend(toastElement);
    }
})(Toast || (Toast = {}));
