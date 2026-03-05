/**
 * A service for interfacing with the input
 *
 * Type: Service
 *
 * ID: inputApiService
 *
 */

(function () {
  'use strict';

  angular.module('inputApi').factory('inputApiService',
      [
        '$resource',
        function($resource) {
          var Input = $resource('/secure/api/inputs/:id', {id: '@id'},{
            'query':  { isArray: false },
            'update': { method: 'PUT' }
          });

          var Output = $resource('/secure/api/outputs/:id', {id: '@id'});

          //------------------------------------
          // getAll 
          //------------------------------------
          function getAll() {
            return Input.query();
          }

          //------------------------------------
          // getInputsForCompany
          //------------------------------------
          function getInputsForCompany(companyId) {
            return Input.query({company_id: companyId});
          }

          //------------------------------------
          // getInputsBySearch
          //------------------------------------
          function getInputsBySearch(companyId, search, limit, offset) {
            return Input.query({company_id: companyId, search: search, limit: limit, offset: offset});
          }

          //------------------------------------
          // getInput
          //------------------------------------
          function getInput(id) {
            return Input.get({id: id});
          }

          //------------------------------------
          // getOutput
          //------------------------------------
          function getOutput(id) {
            return Output.get({id: id});
          }

          //------------------------------------
          // save
          //------------------------------------
          function save(data) {
            var obj = new Input(data);
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
            var obj = new Input(data);
            return obj.$delete();
          }

          return {
            getAll: getAll,
            save: save,
            remove: remove,
            getInput: getInput, 
            getOutput: getOutput, 
            getInputsBySearch: getInputsBySearch,
            getInputsForCompany: getInputsForCompany
          };
        }
      ]);
})();

