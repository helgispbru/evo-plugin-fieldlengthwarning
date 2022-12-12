//<?php
/**
 * FieldLengthWarning
 *
 * Show Warning for Field Length
 *
 * @category    plugin
 * @version     1.0.1
 * @license     The Unlicense https://unlicense.org/
 * @internal    @properties &field_names=Названия полей (параметр name);text;;;Перечислить через запятую. Например: pagetitle,longtitle  &field_lengths=Длины полей;text;;;Перечислить через запятую. Например: 64,128  &recomendedlength=Показывать рекомендуемую длину поля;list;Yes;Yes,No;Yes; &maxlength=Также показывать максимальную длину поля;list;No;Yes,No;No;
 * @internal    @events OnDocFormPrerender
 * @internal    @modx_category Manager and Admin
 * @reportissues https://github.com/helgispbru/evo-plugin-fieldlengthwarning
 * @documentation https://github.com/helgispbru/evo-plugin-fieldlengthwarning
 * @author      helgispbru
 * @lastupdate  2022-12-12
 */
if (!isset($field_names)) {$field_names = '';}
if (!isset($field_lengths)) {$field_lengths = '';}
if (!isset($recomendedlength)) {$recomendedlength = 'Yes';}
if (!isset($maxlength)) {$maxlength = 'No';}

if (strlen($field_names)) {
    $field_names = explode(',', $field_names);
    $field_lengths = explode(',', $field_lengths);
}

$e = &$modx->event;

switch ($e->name) {
    case 'OnDocFormPrerender':
        $rows = [];
        foreach ($field_names as $index => $field) {
            $rows[] = "

            let el" . $field . " = document.querySelectorAll('[name=" . $field . "]');

            if('" . $recomendedlength . "' == 'Yes' || '" . $maxlength . "' == 'Yes') {
                let div = document.createElement('div');
                div.className = '';

                let text = '';
                if('" . $recomendedlength . "' == 'Yes') {
                    text += 'Введено <span class=\"current\">' + el" . $field . "[0].value.length + '</span> символов из <span class=\"recommend\">" . ($field_lengths[$index] ?? "el" . $field . "[0].getAttribute('maxlength')") . "</span>';
                }
                if('" . $maxlength . "' == 'Yes' && el" . $field . "[0].hasAttribute('maxlength')) {
                    text += ', максимум <span class=\"max\">' + el" . $field . "[0].getAttribute('maxlength') + '</span> символов';
                }
                div.innerHTML = text;

                el" . $field . "[0].after(div);
            }

            el" . $field . "[0].addEventListener('keyup', () => {
                if (el" . $field . "[0].nextSibling && el" . $field . "[0].nextSibling.nodeName == 'DIV') {
                    el" . $field . "[0].nextSibling.getElementsByClassName('current')[0].innerText = el" . $field . "[0].value.length;

                    /* меньше */
                    if(el" . $field . "[0].value.length < " . ($field_lengths[$index] ?? "el" . $field . "[0].getAttribute('maxlength')") . ") {
                        if(!el" . $field . "[0].nextSibling.classList.contains('text-success')) {
                            el" . $field . "[0].nextSibling.classList.add('text-success');
                        }
                        if(el" . $field . "[0].nextSibling.classList.contains('text-warning')) {
                            el" . $field . "[0].nextSibling.classList.remove('text-warning');
                        }
                    }
                    /* больше */
                    if(el" . $field . "[0].value.length > " . ($field_lengths[$index] ?? 0) . ") {
                        if(el" . $field . "[0].nextSibling.classList.contains('text-success')) {
                            el" . $field . "[0].nextSibling.classList.remove('text-success');
                        }
                        if(!el" . $field . "[0].nextSibling.classList.contains('text-warning')) {
                            el" . $field . "[0].nextSibling.classList.add('text-warning');
                        }
                    }
                }
            });

            el" . $field . "[0].dispatchEvent(new Event('keyup'));

            ";
        }

        $output = "<script>window.onload = function() { " . implode('', $rows) . " }</script>";
        $e->output($output);
        break;
    default:
        return;
}
