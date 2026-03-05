/**
 * A service for interfacing with the company
 *
 * Type: Service
 *
 * ID: companyApiService
 *
 */

(function () {
  'use strict';

  angular.module('companyApi').factory('companyApiService',
      [
        '$resource',
        function($resource) {
          var Company = $resource('/secure/api/companies/:id', {id: '@id'},{
            'update': { method: 'PUT'}
          });

          var Location = $resource('/secure/api/locations/:id', {id: '@id'},{
            'update': { method: 'PUT'}
          });

          //------------------------------------
          // getAll 
          //------------------------------------
          function getAll() {
            return Company.query();
          }

          //------------------------------------
          // save
          //------------------------------------
          function save(data) {
            var obj = new Company(data);
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
            var obj = new Company(data);
            return obj.$delete();
          }

          //------------------------------------
          // getAllLocations
          //------------------------------------
          function getAllLocations() {
            return Location.query();
          }

          //------------------------------------
          // getLocations
          //------------------------------------
          function getLocations(companyId) {
            return Location.query({company_id: companyId});
          }

          //------------------------------------
          // getLocation
          //------------------------------------
          function getLocation(locationId) {
            return Location.get({id: locationId});
          }

          //------------------------------------
          // saveLocation
          //------------------------------------
          function saveLocation(data) {
            var obj = new Location(data);
            if (data.data.id) {
              return obj.$update({id: data.data.id});
            } else {
              return obj.$save();
            }
          }

          //------------------------------------
          // removeLocation
          //------------------------------------
          function removeLocation(data) {
            var obj = new Location(data);
            return obj.$delete();
          }

          return {
            getAll: getAll,
            save: save,
            remove: remove,
            getLocation: getLocation,
            getLocations: getLocations,
            saveLocation: saveLocation,
            removeLocation: removeLocation,
            getAllLocations: getAllLocations
          };
        }
      ]);
})();


