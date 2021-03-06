<?php
/*
 * Copyright 2015 Centreon (http://www.centreon.com/)
 * 
 * Centreon is a full-fledged industry-strength solution that meets 
 * the needs in IT infrastructure and application monitoring for 
 * service performance.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0  
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * For more information : contact@centreon.com
 * 
 */

namespace CentreonMain\Forms\Validators;

use Centreon\Internal\Di;
use Centreon\Internal\Form\Validators\ValidatorInterface;

use CentreonConfiguration\Repository\ServicetemplateRepository;
use CentreonConfiguration\Repository\ServiceRepository;
use CentreonConfiguration\Repository\HostTemplateRepository;
use CentreonConfiguration\Repository\HostRepository;
use CentreonConfiguration\Repository\CommandRepository;
use CentreonConfiguration\Repository\TrapRepository;
use CentreonConfiguration\Repository\PollerRepository;
use CentreonConfiguration\Repository\ResourceRepository;
use CentreonConfiguration\Models\Poller;

use CentreonAdministration\Repository\ContactRepository;
use CentreonAdministration\Repository\UserRepository;
use CentreonAdministration\Repository\LanguageRepository;
use CentreonAdministration\Repository\DomainRepository;
use CentreonAdministration\Repository\EnvironmentRepository;
use CentreonAdministration\Repository\UsergroupRepository;
use CentreonAdministration\Repository\AclresourceRepository;
use CentreonAdministration\Repository\TagsRepository;

use CentreonBam\Repository\BusinessActivityRepository;
use CentreonBam\Repository\IndicatorRepository;

use CentreonPerformance\Repository\GraphTemplate;

use Centreon\Internal\Exception\Validator\MissingParameterException;
use CentreonConfiguration\Models\Host;


/**
 * @author Lionel Assepo <lassepo@centreon.com>
 * @package Centreon
 * @subpackage Core
 */
class Unique implements ValidatorInterface
{   
    /**
     * 
     * @param string $sModule
     * @param string $sNameObject
     * @param array $aDatas
     * @return mixte
     */
    public static function validateDataSimple($sModule, $sNameObject, $aDatas) 
    {
        $return = '';
        $iObjectId = '';
        
        $oRepository = $sModule."\Repository\\".ucfirst($sNameObject."Repository");
        $oModel = $sModule."\Models\\".ucfirst($sNameObject);
        $sChampUnique = $oModel::getUniqueLabelField();
        
        if (isset($aDatas['extraParams'][$sChampUnique])) {
            $sLabel = $aDatas['extraParams'][$sChampUnique];
                  
            $aParams[$sNameObject] = $sLabel;
                        
            if (isset($aDatas['extraParams']['object_id']) && !empty($aDatas['extraParams']['object_id'])) {
                $iObjectId = $aDatas['extraParams']['object_id'];
            }
            
            try {
                $idReturned = $oRepository::getIdFromUnicity($aParams);
                $return[] = self::compareResponse($iObjectId, $idReturned);

            } catch (MissingParameterException $e) {
                $return[] = 0;
            }
        }
        
        return $return;
    }
    
    /**
     * 
     * @param type $sModule
     * @param type $sNameObject
     * @param array $aDatas
     */
    public static function validateDataService($sModule, $sNameObject, $aDatas) 
    {
        $iObjectId = '';
        $return = '';
        
        $oRepository = $sModule."\Repository\\".ucfirst($sNameObject."Repository");
        $oModel = $sModule."\Models\\".ucfirst($sNameObject);
        $sChampUnique = $oModel::getUniqueLabelField();
        $sChampPk = $oModel::getPrimaryKey();
            
        if (isset($aDatas['extraParams'][$sChampUnique])) {
            $sLabel = $aDatas['extraParams'][$sChampUnique];
        }
        if (isset($aDatas['extraParams'][$sChampPk])) {
            $iId = $aDatas['extraParams'][$sChampPk];
        }

        if (isset($aDatas['extraParams']['service_hosts'])) {
            $aHosts = explode(",", $aDatas['extraParams']['service_hosts']);
            $aHosts = array_diff($aHosts, array( '' ) );

            if (isset($aDatas['extraParams']['object_id']) && !empty($aDatas['extraParams']['object_id'])) {
                $iObjectId = $aDatas['extraParams']['object_id'];
            }

            foreach ($aHosts as $iIdHost) {
                $sHostName = "";
                $aHostName = Host::getParameters($iIdHost, 'host_name');
                if (is_array($aHostName) && isset($aHostName['host_name']) & !empty($aHostName['host_name'])) {
                    $sHostName = $aHostName['host_name'];
                }

                $aParams['host'] = $sHostName;
                $aParams['service'] = $sLabel;
                try {
                    $idReturned = $oRepository::getIdFromUnicity($aParams);

                    $return[] = self::compareResponse($iObjectId, $idReturned);

                } catch (MissingParameterException $e) {
                    $return[] = 0;
                }
            }
        }
        
        return $return;
    }

    /**
     * 
     * @param type $sModule
     * @param type $sNameObject
     * @param array $aDatas
     * @param string $value
     */
    public static function validateDataIndicator($sModule, $sNameObject, $aDatas, $value) 
    {
        $iObjectId = '';
        $return = '';
        $sLabel = '';
       
        $oRepository = $sModule."\Repository\\".ucfirst($sNameObject."Repository");
        
        if (isset($aDatas['extraParams']['kpi_type']) && !empty($value)) {
            if ($aDatas['extraParams']['kpi_type'] == '0' && isset($aDatas['extraParams']['service_id']) && $aDatas['extraParams']['service_id'] == $value) {
                $serviceId = "";
                if (isset($aDatas['extraParams']['service_id'])) {
                    $serviceId = $aDatas['extraParams']['service_id'];
                }
                $aParams['id_ba'] = $aDatas['extraParams']['id_ba'];
                $aParams['serviceIndicator'] = $serviceId;

            } elseif ($aDatas['extraParams']['kpi_type'] == '2' && isset($aDatas['extraParams']['id_indicator_ba']) && $aDatas['extraParams']['id_indicator_ba'] == $value) {
                if (isset($aDatas['extraParams']['id_indicator_ba'])) {
                    $sLabel = $aDatas['extraParams']['id_indicator_ba'];
                }
                $aParams['id_ba'] = $aDatas['extraParams']['id_ba'];
                $aParams['baIndicator'] = $sLabel;

            } elseif ($aDatas['extraParams']['kpi_type'] == '3' && isset($aDatas['extraParams']['boolean_name']) && $aDatas['extraParams']['boolean_name'] == $value) {
                if (isset($aDatas['extraParams']['boolean_name'])) {
                    $sLabel = $aDatas['extraParams']['boolean_name'];
                }
                $aParams['boolean'] = $sLabel;
            }

            try {
                $idReturned = IndicatorRepository::getIdFromUnicity($aParams, $aDatas['extraParams']['kpi_type']);
                $iObjectId = '';

                if (isset($aDatas['extraParams']['object_id']) && !empty($aDatas['extraParams']['object_id'])) {
                    $iObjectId = $aDatas['extraParams']['object_id'];
                }
                $return[] = self::compareResponse($iObjectId, $idReturned);
            } catch (MissingParameterException $e) {
                $return[] = 0;
            }
        }
        return $return;
    }
    
    /**
     * 
     * @param type $sModule
     * @param type $sNameObject
     * @param array $aDatas
     */
    public static function validateDataResource($sModule, $sNameObject, $aDatas) 
    {
        $iObjectId = '';
        $return = '';
        
        $oRepository = $sModule."\Repository\\".ucfirst($sNameObject."Repository");
        $oModel = $sModule."\Models\\".ucfirst($sNameObject);
        $sChampUnique = $oModel::getUniqueLabelField();
        $sChampPk = $oModel::getPrimaryKey();
            
        if (isset($aDatas['extraParams'][$sChampUnique])) {
            $sLabel = $aDatas['extraParams'][$sChampUnique];
        }
        
        if (isset($aDatas['extraParams']['resource_pollers'])) {
            $aPollers = explode(",", $aDatas['extraParams']['resource_pollers']);
            $aPollers = array_map('trim', $aPollers);
            $aPollers = array_diff($aPollers, array( '' ) );

            if (isset($aDatas['extraParams']['resource_name']) && count($aPollers) > 0) {
                $aParams['resources'] = $sLabel;

                foreach ($aPollers as $iIdPoller) {
                    $sPollerName = "";
                    $aPollerName = Poller::getParameters($iIdPoller, 'name');
                    if (is_array($aPollerName) && isset($aPollerName['name']) & !empty($aPollerName['name'])) {
                        $sPollerName = $aPollerName['name'];
                    }

                    $aParams['poller'] = $sPollerName;

                    try {
                        $idReturned = $oRepository::getIdFromUnicity($aParams);
                        $iObjectId = '';

                        if (isset($aDatas['extraParams']['object_id']) && !empty($aDatas['extraParams']['object_id'])) {
                            $iObjectId = $aDatas['extraParams']['object_id'];
                        }
                        $return[] = self::compareResponse($iObjectId, $idReturned);
                    } catch (MissingParameterException $e) {
                        $return[] = 0;
                    }

                }
            }
        }
        return $return;
    }
    
    /**
     * 
     * @param type $sModule
     * @param type $sNameObject
     * @param array $aDatas
     */
    public static function validateDataSpecific($sModule, $oRepository, $oModel, $sNameObject, $aDatas) 
    {
        $iObjectId = '';
        $return = '';
        
        $sChampUnique = $oModel::getUniqueLabelField();
            
        if (isset($aDatas['extraParams'][$sChampUnique])) {
            $sLabel = $aDatas['extraParams'][$sChampUnique];
        
            $aParams[$sNameObject] = $sLabel;
            
            try {
                $idReturned = $oRepository::getIdFromUnicity($aParams);
                $iObjectId = '';

                if (isset($aDatas['extraParams']['object_id']) && !empty($aDatas['extraParams']['object_id'])) {
                    $iObjectId = $aDatas['extraParams']['object_id'];
                }
                $return[] = self::compareResponse($iObjectId, $idReturned); 

            } catch (MissingParameterException $e) {
                $return[] = 0;
            }
        }
        return $return;
    }

    /**
     * 
     * @param type $value
     * @param array $params
     * @return boolean
     */
    
    public function validate($value, $params = array(), $sContext = 'server')
    {
        $db = Di::getDefault()->get('db_centreon');
        $bSuccess = true;
        $resultError = _("Object already exists");
        $sMessage = '';
        
        $aParams = array();
        $aHost = array();
        $sLabel = '';
        $iId = '';
        $return = '';
        $iObjectId = '';
        
        $value = trim($value);
       
        if (isset($params['object'])) {
            switch ($params['object']) {
                case 'poller' :
                case 'host' :
                case 'servicetemplate' :
                case 'command' :
                case 'connector' :
                case 'manufacturer' :
                case 'timeperiod' :
                    $sModule = "CentreonConfiguration";
                    
                    $return = self::validateDataSimple($sModule, $params['object'], $params);
                    break;
                case 'trap' :
                    $sModule = "CentreonConfiguration";
                    
                    $oRepository = $sModule."\Repository\\".ucfirst($params['object']."Repository");
                    $oModel = $sModule."\Models\\".ucfirst($params['object']);
                    
                    $return = self::validateDataSpecific($sModule, $oRepository, $oModel, 'traps', $params);
                    break;
                case 'contact' :
                case 'user' :
                case 'language' :
                case 'domain' :
                case 'environment' :
                case 'tag' :
                case 'usergroup' :
                case 'aclresource' :
                    $sModule = "CentreonAdministration";
                    
                    $return = self::validateDataSimple($sModule, $params['object'], $params);
                    break;
                case 'businessactivity' :
                    $sModule = "CentreonBam";
                    $oRepository = $sModule."\Repository\BusinessActivityRepository";
                    $oModel = $sModule."\Models\BusinessActivity";
                    
                    $return = self::validateDataSpecific($sModule, $oRepository, $oModel, 'bam', $params);
                    break;
                case 'graphtemplate' :
                    $sModule = "CentreonPerformance";
                    
                    $oRepository = $sModule."\Repository\GraphTemplate";
                    $oModel = $sModule."\Models\GraphTemplate";
                    
                    $return = self::validateDataSpecific($sModule, $oRepository, $oModel, $params['object'], $params);
                    break;
                case 'service' :
                    $sModule = "CentreonConfiguration";
                    
                    $return = self::validateDataService($sModule, $params['object'], $params);
                    break;
                case 'resource' :
                    $sModule = "CentreonConfiguration";
                    
                    $return = self::validateDataResource($sModule, $params['object'], $params);
                    break;
                case 'hosttemplate' :
                    $sModule = "CentreonConfiguration";
                    $oRepository = $sModule."\Repository\HostTemplateRepository";
                    $oModel = $sModule."\Models\\".ucfirst($params['object']);
                    
                    $return = self::validateDataSpecific($sModule, $oRepository, $oModel, $params['object'], $params);
                    break;
                case 'indicator' :
                    $sModule = "CentreonBam";
                    $return = self::validateDataIndicator($sModule, $params['object'], $params, $value);
                    break;
            }
        }
      
        if (is_array($return)) {
            foreach($return as $valeur) {
                if ($valeur > 0) {
                    $bSuccess = false;
                    $sMessage = $resultError;
                    break;
                }
            } 
        } else {
            if ($return > 0) {
                $bSuccess = false;
                $sMessage = $resultError;
            }
        }
        
        if ($sContext == 'client') {
            if (empty($sMessage)) 
                $sMessage = true;
            
            $reponse = $sMessage;
        } else {
            $reponse = array(
                'success' => $bSuccess, 
                'error' => $sMessage
            );
        }

        return $reponse;
    }
    /**
     * 
     * @param int $iObjectId
     * @param int $iIdReturned
     * @return int
     */
    private function compareResponse($iObjectId, $iIdReturned)
    {
        $iRetour = '';
        if (!empty($iIdReturned)) {
            if ($iObjectId == $iIdReturned) {
                $iRetour = 0;
            } else {
                $iRetour = $iIdReturned;
            }
        } else {
            $iRetour = $iIdReturned;
        }
        return $iRetour;
    }
}
