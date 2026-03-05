/** 
 * Message Box
 * 
 * Type: Controller
 * 
 * ID: messageBoxController
 * 
 */
(function () {
    'use strict';

    angular.module('messageBox').controller('messageBoxController',
        [
        '$scope',
        '$uibModalInstance',
        'messageBoxService',
        'title',
        'message',
        'button1Text',
        'button2Text',
        function ($scope, $uibModalInstance, messageBoxService, title, message, button1Text, button2Text) {
            //----------------------------------------------
            // initScope
            //----------------------------------------------
            function initScope() {
                // Properties
                $scope.title = title;
                $scope.message = message;
                $scope.button1Text = button1Text;
                $scope.button2Text = button2Text;

                // Functions
                $scope.onButton1 = onButton1;
                $scope.onButton2 = onButton2;
            }

            //----------------------------------------------
            // onButton1
            //----------------------------------------------
            function onButton1() {
                $uibModalInstance.close(messageBoxService.buttonResults.button1);
            }

            //----------------------------------------------
            // onButton2
            //----------------------------------------------
            function onButton2() {
                $uibModalInstance.close(messageBoxService.buttonResults.button2);
            }

            initScope();
        }]);
})();
