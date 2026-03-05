/**
 * Displays a required asterisk 
 *
 * Type: Directive
 *
 * ID: autoDisplayRequiredAsterisk
 *
 */

(function () {
  'use strict';

  angular.module('displayRequiredAsterisk').directive('autoDisplayRequiredAsterisk',
      [
        '$rootScope',
        '$document',
        function($rootScope, $document) {
          return {
            restrict: 'A',
            link: function(scope, element, attrs) {
              var releaseWatch = scope.$watch(function() {
                return document.all.length;
              },function() {
                $rootScope.$evalAsync(function () {

                  $('input,textarea,select').filter('[required]').each(function() {
                    $('label[for="' + $(this).attr('id') + '"]').addClass('requiredAsterisk');
                  });

                  $('input,textarea,select').filter('[ng-required]').each(function() {
                    $('label[for="' + $(this).attr('id') + '"]').addClass('requiredAsterisk');
                  });

                  $('div.ui-select-container').filter('[ng-required]').each(function() {
                    $('label[for="' + $(this).attr('id') + '"]').addClass('requiredAsterisk');
                  });

                });
              });
            
              scope.$on('$destroy', function() {
                releaseWatch();
              });
            }
          };
        }
      ]);
})();


