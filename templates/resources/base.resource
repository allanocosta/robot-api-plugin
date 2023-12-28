*** Settings ***
Documentation       Resource com as keywords gerais do projeto

Library             Collections
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             JSONLibrary


*** Variables ***
${API_URL}          ${EMPTY}
${API_VERSION}      /v1
${RESPONSE}         ${null}


*** Keywords ***
# LOGS
Ocultar Logs
    ${prev_lvl}             Set Log Level           NONE
    Set Suite Variable      ${prev_lvl}

Restaurar Logs
    IF    $prev_lvl != 'NONE'    Set Log Level    ${prev_lvl}

# SESSIONS

Conectar API
    Create Session
    ...                     FakeRestApi
    ...                     ${API_URL}/${API_VERSION}
    ...                     verify=False
    ...                     disable_warnings=1
    Set Suite Variable      ${API_URL}

Desconectar Todas As Seções
    Delete All Sessions

# KEYWORDS JSON FILES

Obter Fixtures
    [Arguments]             ${FILE_NAME}            ${METODO}

    ${DATA}                 Load Json From File
    ...                     ${CURDIR}/../fixtures/${FILE_NAME}.json
    ...                     encoding=utf-8
    Log                     ${DATA}
    RETURN                  ${DATA}[${METODO}]

# KEYWORDS GERAIS

Comparar Valores
    [Arguments]             ${value1}               ${value2}

    FOR    ${KEY}    IN    @{value1.keys()}
        Should Be Equal As Strings                      ${value1["${KEY}"]}     ${value2["${KEY}"]}
    END

Response Pelo Menos Um Valor Igual Ao Do JSON
    [Arguments]             ${FILE_DATA}

    ${RES_DATA}             Set Variable            ${RESPONSE.json()}
    ${passou}               Set Variable            False

    FOR    ${ITEM}    IN    @{RES_DATA["data"]["pageContent"]}
        ${status}               ${value}                Run Keyword And Ignore Error
        ...                     Comparar Valores        ${FILE_DATA["response"]}                        ${ITEM}
        IF    $status == 'PASS'
            ${passou}               Set Variable            True
            BREAK
        END
    END
    Log                     ${status}
    Log                     ${value}
    Should Be True          ${passou}

Response Todos Os Valores Devem Ser Iguais Ao Do JSON
    [Arguments]             ${FILE_DATA}

    ${RES_DATA}             Set Variable            ${RESPONSE.json()}

    FOR    ${KEY}    IN    @{FILE_DATA["response"][0].keys()}
        Should Be Equal As Strings
        ...                     ${FILE_DATA["response"][0]["${KEY}"]}
        ...                     ${RES_DATA[0]["${KEY}"]}
    END

Response Compara Todos Os Valores Do JSON Com Response
    [Arguments]             ${FILE_DATA}

    ${RES_DATA}             Set Variable            ${RESPONSE.json()}

    FOR    ${ITEM}    IN    @{FILE_DATA["response"]}
        FOR    ${KEY}    IN    @{${ITEM}.keys()}
            IF    ${KEY} in ${RES_DATA[0]}
                Should Be Equal As Strings
                ...                     ${ITEM}[${KEY}]
                ...                     ${RES_DATA[0][${KEY}]}
            END
        END
    END

Response Validar JSON Com API AAAA
    [Arguments]             ${FILE_DATA}

    ${RES_DATA}             Set Variable            ${RESPONSE.json()}

    FOR    ${json_item}    IN    @{FILE_DATA['response']}
        ${json_id}              Set Variable            ${json_item['id']}
        ${json_title}           Set Variable            ${json_item['title']}
        ${json_completed}       Set Variable            ${json_item['completed']}

        FOR    ${resp_item}    IN    @{RES_DATA}
            ${resp_id}              Set Variable            ${resp_item['id']}
            ${resp_title}           Set Variable            ${resp_item['title']}
            ${resp_completed}       Set Variable            ${resp_item['completed']}
            IF    $json_id == $resp_id and $json_title == $resp_title and $json_completed == $resp_completed
                Log                     JSON data matches API response
            ELSE
                Fail                    JSON data does not match API response
            END
        END
    END

Response Validar JSON Com API Completo
    [Arguments]             ${FILE_DATA}

    ${RES_DATA}             Set Variable            ${RESPONSE.json()}
    ${keys}                 Get Dictionary Keys     ${FILE_DATA}[response]

    FOR    ${key}    IN    @{keys}
        ${json_value}           Get From Dictionary     ${FILE_DATA}[response]                          ${key}
        ${resp_value}           Get From Dictionary     ${RES_DATA}             ${key}

        IF    $json_value == $resp_value
            Log                     A chave ${key} do JSON corresponde é igual a resposta da API.
        ELSE
            Fail                    A chave ${key} do JSON não corresponde a resposta da API.
        END
    END
