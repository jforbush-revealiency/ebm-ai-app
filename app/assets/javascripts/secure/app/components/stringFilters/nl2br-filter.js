/** 
 * A filter that replaces newline with <br/> 
 * 
 * Type: Filter
 * 
 * ID: nl2br 
 * 
 */
(function () {
    'use strict';

    angular.module('stringFilters').filter('nl2br', [
        function () {
            return function(text) {
              if (!text) return text;
              return text.replace(/\n\r?/g, '<br/>');
            };
        }
    ]);

})();
