/** 
 * A service for saving the state of the page.
 * 
 * Type: Service
 * 
 * ID: pageSettings
 * 
 */
(function () {
    'use strict';

    angular.module('pageSettings').factory('pageSettingsService',
        [
            function () {

                var _settings = {};
                
                //----------------------------------------------
                // save
                //----------------------------------------------
                function save(pageName, settings) {
                    _settings[pageName] = settings;
                }

                //----------------------------------------------
                // getPageSettings
                //----------------------------------------------
                function getPageSettings(pageName) {
                    return _settings[pageName];
                }

                //----------------------------------------------
                // getPageAttribute
                //----------------------------------------------
                function getPageAttribute(pageName, attribute) {
                    var pageSettings = _settings[pageName];
                    if (pageSettings) {
                        return pageSettings[attribute];
                    }

                    return null;
                }

                //----------------------------------------------
                // savePageAttribute
                //----------------------------------------------
                function savePageAttribute(pageName, attribute, value) {
                    var pageSettings = _settings[pageName];
                    if (pageSettings) {
                        pageSettings[attribute] = value;
                    }
                }

                //----------------------------------------------
                // remove
                //----------------------------------------------
                function remove(pageName) {
                    delete _settings[pageName];
                }

                return {
                    save: save,
                    getPageSettings: getPageSettings,
                    getPageAttribute: getPageAttribute,
                    savePageAttribute: savePageAttribute,
                    remove: remove
                };
            }
        ]
    );
})();