/**
 * A service for interfacing with the manufacturer
 * 
 * Type: Service
 *
 * ID: manufacturerApiService
 *
 */

(function () {
  'use strict';

  angular.module('manufacturerApi').factory('manufacturerApiService',
      [
        '$resource',
        function($resource) {
          var Manufacturer = $resource('/secure/api/manufacturers/:id', {id: '@id'}, {
            'update': { method: 'PUT'}
          });

          //------------------------------------
          // getAll 
          //------------------------------------
          function getAll() {
            return Manufacturer.query();
          }

          //------------------------------------
          // save
          //------------------------------------
          function save(data) {
            var obj = new Manufacturer(data);
            if (data.data.id) {
              return obj.$update({id: data.data.id});
            } else {
              return obj.$save();
            }
          }

          //------------------------------------
          // remove
          //------------------------------------
          function remove(manufacturer) {
            var ManufacturerObject = new Manufacturer(manufacturer);
            return ManufacturerObject.$delete();
          }

          return {
            getAll: getAll,
            save: save,
            remove: remove
          };
        }
      ]);
})();


