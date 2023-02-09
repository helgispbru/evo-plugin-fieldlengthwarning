//<?php
/**
 * Field Length Warning
 *
 * Show Warning for Field Length
 *
 * @category    plugin
 * @version     1.0.5
 * @license     The Unlicense https://unlicense.org/
 * @internal    @properties &fields=Названия полей (параметр name);text;;;Перечислить поля через запятую, длины через двоеточие. Например: pagetitle:32:64,longtitle:64:128 &recomendedlength=Показывать рекомендуемую длину поля;list;Yes,No;Yes &maxlength=Показывать максимальную длину поля;list;Yes,No;Yes
 * @internal    @events OnDocFormPrerender
 * @internal    @modx_category Manager and Admin
 * @reportissues https://github.com/helgispbru/evo-plugin-fieldlengthwarning
 * @documentation https://github.com/helgispbru/evo-plugin-fieldlengthwarning
 * @author      helgispbru
 * @lastupdate  2023-02-09
 */
if (!isset($fields)) {$fields = '';}
if (!isset($recomendedlength)) {$recomendedlength = 'Yes';}
if (!isset($maxlength)) {$maxlength = 'No';}

if (strlen($fields) == 0) {
    return;
}

if (strpos($fields, ',') !== false) {
    $fields = explode(',', $fields);
} else {
    $fields = [$fields];
}

$arr = [];
foreach ($fields as $el) {
    if (strpos($el, ':') !== false) {
        $tmp = explode(':', $el);
        if (count($tmp) == 2) {
            $arr[$tmp[0]] = [$tmp[1]];
        } else {
            $arr[$tmp[0]] = [$tmp[1], $tmp[2]];
        }
    } else {
        $arr[$el] = [];
    }
}
$fields = $arr;

$e = &$modx->event;

switch ($e->name) {
    case 'OnDocFormPrerender':
        $rows = [];
        foreach ($fields as $name => $limits) {
            $rows[] = "

            let el" . $name . " = document.querySelectorAll('[name=" . $name . "]');

            if('" . $recomendedlength . "' == 'Yes' || '" . $maxlength . "' == 'Yes') {
                let div = document.createElement('div');

                let text = ``;
                if('" . $recomendedlength . "' == 'Yes') {
                    text += 'Введено <span class=\"current\">' + el" . $name . "[0].value.length + plural(el" . $name . "[0].value.length, ' символ', ' символа', ' символов') + '</span>';

                    if(" . count($limits) . " > 0) {
                        text += ', рекомендуется';

                        if(" . count($limits) . " >= 1) {
                            text += ' от <span class=\"recommend\">' + " . ($limits[0] ?? "el" . $name . "[0].getAttribute('maxlength')") . " + '</span>';
                        }
                        if(" . count($limits) . " == 2) {
                            text += ' до <span class=\"recommend\">' + " . ($limits[1] ?? "el" . $name . "[0].getAttribute('maxlength')") . " + '</span>';
                        }
                    }
                }
                if('" . $maxlength . "' == 'Yes' && el" . $name . "[0].getAttribute('maxlength') > 0) {
                    text += ', максимум <span class=\"max\">' + el" . $name . "[0].getAttribute('maxlength') + '</span>';
                }
                div.innerHTML = text;

                el" . $name . "[0].after(div);
            }

            el" . $name . "[0].addEventListener('keyup', () => {
                if (el" . $name . "[0].nextSibling && el" . $name . "[0].nextSibling.nodeName == 'DIV') {
                    const length = el" . $name . "[0].value.length;
                    const maxlength = el" . $name . "[0].getAttribute('maxlength');

                    el" . $name . "[0].nextSibling.getElementsByClassName('current')[0].innerText = length + ' ' + plural(length, 'символ', 'символа', 'символов');

                    switch(" . count($limits) . ") {
                        /* нет лимитов */
                        case 0:
                            el" . $name . "[0].nextSibling.classList.add('text-secondary');
                            break;
                        /* только min */
                        case 1:
                            /* меньше */
                            if(length < " . ($limits[0] ?? "maxlength") . ") {
                                if(el" . $name . "[0].nextSibling.classList.contains('text-success')) {
                                    el" . $name . "[0].nextSibling.classList.remove('text-success');
                                }
                                if(!el" . $name . "[0].nextSibling.classList.contains('text-warning')) {
                                    el" . $name . "[0].nextSibling.classList.add('text-warning');
                                }
                            }
                            /* больше */
                            if(length > " . ($limits[0] ?? "maxlength") . ") {
                                if(!el" . $name . "[0].nextSibling.classList.contains('text-success')) {
                                    el" . $name . "[0].nextSibling.classList.add('text-success');
                                }
                                if(el" . $name . "[0].nextSibling.classList.contains('text-warning')) {
                                    el" . $name . "[0].nextSibling.classList.remove('text-warning');
                                }
                            }
                            break;
                        /* мин и макс */
                        case 2:
                            /* меньше */
                            if(length < " . ($limits[0] ?? "maxlength") . ") {
                                if(el" . $name . "[0].nextSibling.classList.contains('text-success')) {
                                    el" . $name . "[0].nextSibling.classList.remove('text-success');
                                }
                                if(!el" . $name . "[0].nextSibling.classList.contains('text-warning')) {
                                    el" . $name . "[0].nextSibling.classList.add('text-warning');
                                }
                                if(el" . $name . "[0].nextSibling.classList.contains('text-danger')) {
                                    el" . $name . "[0].nextSibling.classList.remove('text-danger');
                                }
                            }
                            /* между */
                            if(length > " . ($limits[0] ?? "(maxlength - 1)") . " && length < " . ($limits[1] ?? "maxlength") . ") {
                                if(!el" . $name . "[0].nextSibling.classList.contains('text-success')) {
                                    el" . $name . "[0].nextSibling.classList.add('text-success');
                                }
                                if(el" . $name . "[0].nextSibling.classList.contains('text-warning')) {
                                    el" . $name . "[0].nextSibling.classList.remove('text-warning');
                                }
                                if(el" . $name . "[0].nextSibling.classList.contains('text-danger')) {
                                    el" . $name . "[0].nextSibling.classList.remove('text-danger');
                                }
                            }
                            /* больше */
                            if(length > " . ($limits[1] ?? ($limits[0] ?? "maxlength")) . ") {
                                if(el" . $name . "[0].nextSibling.classList.contains('text-success')) {
                                    el" . $name . "[0].nextSibling.classList.remove('text-success');
                                }
                                if(el" . $name . "[0].nextSibling.classList.contains('text-warning')) {
                                    el" . $name . "[0].nextSibling.classList.remove('text-warning');
                                }
                                if(!el" . $name . "[0].nextSibling.classList.contains('text-danger')) {
                                    el" . $name . "[0].nextSibling.classList.add('text-danger');
                                }
                            }
                            break;
                    }
                }
            });

            el" . $name . "[0].dispatchEvent(new Event('keyup'));

            ";
        }

        $output = "<script>let plural = function(n, form1, form2, form5) {
            n = Math.abs(n) % 100;
            n1 = n % 10;
            if (n > 10 && n < 20) return form5;
            if (n1 > 1 && n1 < 5) return form2;
            if (n1 == 1) return form1;
            return form5;
        };
        window.onload = function() { " . implode('', $rows) . " };
        </script>";
        $e->output($output);
        break;
    default:
        return;
}
