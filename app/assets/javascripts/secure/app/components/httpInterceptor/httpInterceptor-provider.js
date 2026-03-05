/**
 * A provider for the http interface 
 *
 * Type: Provider
 *
 * ID: httpInterceptorProvider
 *
 */

(function () {
  'use strict';

  angular.module('httpInterceptor').provider('httpInterceptor', 
    function() {
      this.$get = ['$q', '$log', '$injector', function($q, $log, $injector) {
        function handleError(errors) {
          $log.error(errors);
          var messageBoxService = $injector.get('messageBoxService');
          var message = '';
          if (_.isObject(errors.data)) {
            if (!errors.data.error) {
              var numErrors = 0;
              _.each(errors.data, function(value, key) {
                _.each(value, function(error) {
                  if (key === 'base') {
                    message = message + error + '.<br/>';
                  } else {
                    var newKey = key;
                    newKey = key.replace(/_/g, ' ');
                    message = message + 'The <strong>' + newKey + '</strong> ' + error + '.<br/>';
                  }

                  numErrors++;
                });
              });
              var errorText = 'error';
              if (numErrors > 1) {
                errorText = 'error';
              }
              message = message + '<br/> Please correct the ' + errorText +' and try again.';

            } else {
              numErrors++;
              message = message + errors.data.error;
            }
          } else if (errors.data) {
            message = errors.data.substring(0, 250);
          } else {
            if (errors.statusText === 'Unauthorized') {
              message = 'You are not authorized to view this page.';
            }
          }

          messageBoxService.show('md',
                                 'Errors were detected',
                                 message,
                                 'OK');

        }

        return {
          'responseError': function(response) {
            handleError(response);
            return $q.reject(response);
          }
        };
      }];
    });
})();


