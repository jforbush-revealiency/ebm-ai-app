/**
 * A service for interfacing with the drive types
 *
 * Type: Service
 *
 * ID: driveTypeApiService
 *
 */

(function () {
  'use strict';

  angular.module('driveTypeApi').factory('driveTypeApiService',
      [
        '$resource',
        function($resource) {
          var DriveType = $resource('/secure/api/drive_types/:id', {id: '@id'},{
            'update': { method: 'PUT'}
          });

          //------------------------------------
          // getAll 
          //------------------------------------
          function getAll() {
            return DriveType.query();
          }

          //------------------------------------
          // save
          //------------------------------------
          function save(data) {
            var obj = new DriveType(data);
            if (data.data.id) {
              return obj.$update({id: data.data.id});
            } else {
              return obj.$save();
            }
          }

          //------------------------------------
          // remove
          //------------------------------------
          function remove(driveType) {
            var driveTypeObject = new DriveType(driveType);
            return driveTypeObject.$delete();
          }

          return {
            getAll: getAll,
            save: save,
            remove: remove
          };
        }
      ]);
})();


