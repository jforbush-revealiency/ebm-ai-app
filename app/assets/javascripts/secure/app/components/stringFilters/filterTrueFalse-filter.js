/** 
 * A filter that displays yes or no instead of true or false
 * 
 * Type: Filter
 * 
 * ID: true_false 
 * 
 */
(function () {
    'use strict';

    angular.module('stringFilters').filter('true_false', [
        function () {
            return function(text, length, end) {
              if (text) {
                return 'Yes';
              }
              return 'No';
            };
        }
    ]);

})();
