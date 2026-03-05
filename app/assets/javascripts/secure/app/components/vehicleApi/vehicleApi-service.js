/**
 * A service for interfacing with the vehicles
 *
 * Type: Service
 *
 * ID: vehicleApiService
 *
 */

(function () {
  'use strict';

  angular.module('vehicleApi').factory('vehicleApiService',
      [
        '$resource',
        function($resource) {
          var Vehicle = $resource('/secure/api/vehicles/:id', {id: '@id'},{
            'update': { method: 'PUT'}
          });

          //------------------------------------
          // getAll 
          //------------------------------------
          function getAll() {
            return Vehicle.query();
          }

          //------------------------------------
          // getVehiclesByCompany
          //------------------------------------
          function getVehiclesByCompany(company_id) {
            return Vehicle.query({company_id: company_id});
          }

          //------------------------------------
          // getVehiclesByLocation
          //------------------------------------
          function getVehiclesByLocation(location_id) {
            return Vehicle.query({location_id: location_id});
          }

          //------------------------------------
          // save
          //------------------------------------
          function save(data) {
            var obj = new Vehicle(data);
            if (data.data.id) {
              return obj.$update({id: data.data.id});
            } else {
              return obj.$save();
            }
          }

          //------------------------------------
          // remove
          //------------------------------------
          function remove(data) {
            var obj = new Vehicle(data);
            return obj.$delete();
          }

          return {
            getAll: getAll,
            save: save,
            remove: remove,
            getVehiclesByCompany: getVehiclesByCompany,
            getVehiclesByLocation: getVehiclesByLocation
          };
        }
      ]);
})();


