*** Settings ***
Documentation       Resource do Operation Log Acesso

Resource            base.resource


*** Variables ***
${ID}           ${EMPTY}
${RESPONSE}     ${null}


*** Keywords ***
GET Activities
    [Arguments]             ${DATA}

    ${campo}                Set Variable            id
    ${status_code}          Convert To String       ${DATA}[statusCode]

    ${HEADERS}              Create Dictionary
    ...                     accept=text/plain; v=1.0
    ...                     Content-Type=application/json; v=1.0

    IF    $campo in ${DATA}[payload]
        ${RESPONSE}             GET On Session
        ...                     FakeRestApi
        ...                     /Activities/${DATA}[payload][id]
        ...                     headers=${HEADERS}
        ...                     expected_status=${status_code}

        Set Test Variable       ${RESPONSE}
    ELSE IF    $ID == ''
        ${RESPONSE}             GET On Session
        ...                     FakeRestApi
        ...                     /Activities
        ...                     headers=${HEADERS}
        ...                     expected_status=${status_code}

        Set Test Variable       ${RESPONSE}
    END

POST Activities
    ${HEADERS}              Create Dictionary       accept=text/plain; v=1.0                        Content-Type=application/json; v=1.0
    ${RESPONSE}             POST On Session
    ...                     FakeRestApi
    ...                     /Activities
    ...                     headers=${HEADERS}
    Set Test Variable       ${RESPONSE}

Response Body Deve Estar Vazio
    Should Be Empty         ${RESPONSE.text}

Response Validar JSON Com API
    [Arguments]             ${DATA}

    ${RES_DATA}             Set Variable            ${RESPONSE.json()}

    FOR    ${json_item}    IN    @{DATA['response']}
        FOR    ${resp_item}    IN    @{RES_DATA}
            ${json_id}              Set Variable            ${json_item['id']}
            ${resp_id}              Set Variable            ${resp_item['id']}

            IF    $json_id != $resp_id    CONTINUE
            ${keys}                 Get Dictionary Keys     ${json_item}

            FOR    ${key}    IN    @{keys}
                ${json_value}           Get From Dictionary     ${json_item}            ${key}
                ${resp_value}           Get From Dictionary     ${resp_item}            ${key}

                IF    $json_value == $resp_value
                    Log                     A chave ${key} do JSON corresponde é igual a resposta da API.
                ELSE
                    Fail                    A chave ${key} do JSON não corresponde a resposta da API.
                END
            END
        END
    END
