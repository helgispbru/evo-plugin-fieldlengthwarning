//<?php
/**
 * FieldLengthWarning
 *
 * Show Warning for Field Length
 *
 * @category    plugin
 * @version     1.0.3
 * @license     The Unlicense https://unlicense.org/
 * @internal    @properties &fields=Названия полей (параметр name);text;;;Перечислить через запятую, длины через двоеточие. Например: pagetitle:64,longtitle:128 &recomendedlength=Показывать рекомендуемую длину поля;list;Yes,No;Yes &maxlength=Показывать максимальную длину поля;list;Yes,No;Yes
 * @internal    @events OnDocFormPrerender
 * @internal    @modx_category Manager and Admin
 * @reportissues https://github.com/helgispbru/evo-plugin-fieldlengthwarning
 * @documentation https://github.com/helgispbru/evo-plugin-fieldlengthwarning
 * @author      helgispbru
 * @lastupdate  2022-12-12
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
    $tmp = explode(':', $el);
    $arr[$tmp[0]] = $tmp[1];
}
$fields = $arr;

$e = &$modx->event;

switch ($e->name) {
    case 'OnDocFormPrerender':
        $rows = [];
        foreach ($fields as $name => $length) {
            $rows[] = "

            let el" . $name . " = document.querySelectorAll('[name=" . $name . "]');

            if('" . $recomendedlength . "' == 'Yes' || '" . $maxlength . "' == 'Yes') {
                let div = document.createElement('div');
                div.className = '';

                let text = '';
                if('" . $recomendedlength . "' == 'Yes') {
                    text += 'Введено <span class=\"current\">' + el" . $name . "[0].value.length + '</span> символов из <span class=\"recommend\">" . ($length ?? "el" . $name . "[0].getAttribute('maxlength')") . "</span>';
                }
                if('" . $maxlength . "' == 'Yes' && el" . $name . "[0].hasAttribute('maxlength')) {
                    text += ', максимум <span class=\"max\">' + el" . $name . "[0].getAttribute('maxlength') + '</span> символов';
                }
                div.innerHTML = text;

                el" . $name . "[0].after(div);
            }

            el" . $name . "[0].addEventListener('keyup', () => {
                if (el" . $name . "[0].nextSibling && el" . $name . "[0].nextSibling.nodeName == 'DIV') {
                    el" . $name . "[0].nextSibling.getElementsByClassName('current')[0].innerText = el" . $name . "[0].value.length;

                    /* меньше */
                    if(el" . $name . "[0].value.length < " . ($length ?? "el" . $name . "[0].getAttribute('maxlength')") . ") {
                        if(!el" . $name . "[0].nextSibling.classList.contains('text-success')) {
                            el" . $name . "[0].nextSibling.classList.add('text-success');
                        }
                        if(el" . $name . "[0].nextSibling.classList.contains('text-warning')) {
                            el" . $name . "[0].nextSibling.classList.remove('text-warning');
                        }
                    }
                    /* больше */
                    if(el" . $name . "[0].value.length > " . ($length ?? 0) . ") {
                        if(el" . $name . "[0].nextSibling.classList.contains('text-success')) {
                            el" . $name . "[0].nextSibling.classList.remove('text-success');
                        }
                        if(!el" . $name . "[0].nextSibling.classList.contains('text-warning')) {
                            el" . $name . "[0].nextSibling.classList.add('text-warning');
                        }
                    }
                }
            });

            el" . $name . "[0].dispatchEvent(new Event('keyup'));

            ";
        }

        $output = "<script>window.onload = function() { " . implode('', $rows) . " }</script>";
        $e->output($output);
        break;
    default:
        return;
}
