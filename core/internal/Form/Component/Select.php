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

namespace Centreon\Internal\Form\Component;

use Centreon\Internal\Di;

/**
 * @author Lionel Assepo <lassepo@centreon.com>
 * @package Centreon
 * @subpackage Core
 */
class Select extends Component
{
    /**
     * 
     * @param array $element
     * @return array
     */
    public static function renderHtmlInput(array $element)
    {
        $tpl = Di::getDefault()->get('template');
        // Load CssFile
        $tpl->addCss('select2.css')
            ->addCss('select2-bootstrap.css');

        // Load JsFile
        $tpl->addJs('jquery.select2/select2.min.js');

        if (isset($element['label_defaultValuesRoute'])) {
            $element['label_defaultValuesRoute'] = Di::getDefault()
                            ->get('router')
                            ->getPathFor($element['label_defaultValuesRoute'], $element['label_extra']);
        }
        if (isset($element['label_listValuesRoute'])) {
            $element['label_listValuesRoute'] = Di::getDefault()
                            ->get('router')
                            ->getPathFor($element['label_listValuesRoute'], $element['label_extra']);
        }
        
        $addClass = '';
        $required = '';
        if (isset($element['label_mandatory']) && $element['label_mandatory'] == "1") {
            $addClass .= 'mandatory-field ';
            $required .= ' required';
        }
        $addJs = '';
        if (isset($element['label_ordered']) && $element['label_ordered']) {
            $addJs = '$("#'
                .$element['name']
                .'").on("change", function() { $("#'
                .$element['name']
                .'_val").html($("#'
                .$element['name']
                .'").val());});';

            $addJs .= '$("#'.$element['name'].'").select2("container").find("ul.select2-choices").sortable({
                    containment: "parent",
                    start: function() { $("#'.$element['name'].'").select2("onSortStart"); },
                    update: function() { $("#'.$element['name'].'").select2("onSortEnd"); }
                  });'."\n";
        }

        if (!isset($element['label_multiple'])) {
            $element['label_multiple'] = 0;
        }

        $myHtml = '<input '
            . 'class="form-control '
            . $addClass
            . '" id="'.$element['name']
            . '" name="' . $element['name']. '"';
        if (!empty($element['label_parent_field']) && isset($element['label_parent_value'])) {

            $myHtml .= ' data-parentfield="' . $element['label_parent_field'] . '"';
            $myHtml .= ' data-parentvalue="' . $element['label_parent_value'] . '"';
        }
        
        $escapedName = str_replace(']','\\\]',str_replace('[','\\\[',$element['name']));
        $myHtml .= ' style="width: 100%;" type="hidden" value=" "' . $required . ' />';
        $myHtml .= '<cite></cite>';
        $myJs = ''
            . '$("#'.$escapedName.'").select2({'
                . 'placeholder:"'.$element['label_label'].'", '
                . 'multiple:'.(int)$element['label_multiple'].', '
                . 'allowClear: true, '
                . 'formatResult: select2_formatResult, '
                . 'formatSelection: select2_formatSelection, ';
        if (isset($element['label_selectData'])) {
            if (is_array($element['label_selectData'])) {
                $datas = json_encode($element['label_selectData']);
            } else {
                $datas = $element['label_selectData'];
            }
            $myJs .= 'data: { results: ' . $datas . ' },';
        } elseif (isset($element['label_defaultValuesRoute'])) {
            $myJs .= ''
                . 'ajax: {'
                    .'data: function(term, page) {'
                        .'return { '
                            .'q: term, '
                        .'};'
                    .'},'
                    .'dataType: "json", '
                    .'url:"'.$element['label_defaultValuesRoute'].'", '
                    .'results: function (data){ '
                        .'return {results:data, more:false}; '
                    .'}'
                .'},';
        }
        $initCallback = '';
        if (isset($element['label_initCallback']) && $element['label_initCallback'] != '') {
            $initCallback = '
                if ( typeof ' . $element['label_initCallback'] . ' === "function" ) {
                    ' . $element['label_initCallback'] . '(data);
                } else {
                    callFunction = "' . $element['label_initCallback'] . '(data)";
                    eval(callFunction);
                }
            ';
        }

        if (isset($element['label_selectDefault']) && $element['label_selectDefault'] != "[]") {
            $myJs .= ''
                .'initSelection: function(element, callback) {'
                    .'var data = '.$element['label_selectDefault'].';'
                    .'callback(data);'
                    .'id = $(element).val();'
                    .'if (data.id) {'
                    .'  $(element).val(data.id);'
                    .'}'
                    .$initCallback
                .'}';
        } elseif (isset($element['label_listValuesRoute'])) {
            $myJs .= ''
                .'initSelection: function(element, callback) { '
                    .'var id=$(element).val();'
                    .'if (id == " ") {
                        $.ajax("'.$element['label_listValuesRoute'].'", {
                            dataType: "json"
                        }).done(function(data) {
                            if (data.length > 0 || data.id) {
                                callback(data);
                                id = $(element).val();
                                if (data.id) {
                                    $(element).val(data.id);
                                }
                                if (id.match(/^,/)) {
                                    $(element).val(id.substring(1, id.length));
                                } ' . $initCallback . '
                                $(element).trigger("change");
                            }
                        });
                     }
                },';
        }
        $myJs .= ''
            .'});'."\n";
        
        $myJs .= $addJs;
        
        
        return array(
            'html' => $myHtml,
            'js' => $myJs
        );
    }
}
