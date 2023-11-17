*** Settings ***
Documentation       Resource do Operation Log Acesso

Resource            ${CURDIR}/../base.resource


*** Variables ***
${ID}           ${EMPTY}
${RESPONSE}     ${null}


*** Keywords ***
POST Activities
    ${HEADERS}              Create Dictionary       accept=text/plain; v=1.0                        Content-Type=application/json; v=1.0
    ${RESPONSE}             POST On Session
    ...                     FakeRestApi
    ...                     /Activities
    ...                     headers=${HEADERS}
    Set Test Variable       ${RESPONSE}

GET Activities
    [Arguments]             ${FILE_DATA}

    ${campo}                Set Variable            id
    ${status_code}          Convert To String       ${FILE_DATA}[statusCode]

    IF    $campo in ${FILE_DATA}[payload]
        ${ID}                   Set Variable            ${FILE_DATA}[payload][id]
    END

    ${HEADERS}              Create Dictionary
    ...                     accept=text/plain; v=1.0
    ...                     Content-Type=application/json; v=1.0

    ${RESPONSE}             GET On Session
    ...                     FakeRestApi
    ...                     /Activities/${ID}
    ...                     headers=${HEADERS}
    ...                     expected_status=${status_code}

    Set Test Variable       ${RESPONSE}

Response Body Deve Estar Vazio
    Should Be Empty         ${RESPONSE.text}

Response Validar JSON Com API
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
            IF    $json_id != $resp_id    CONTINUE
            IF    $json_title == $resp_title and $json_completed == $resp_completed
                Log                     JSON data matches API response
            ELSE
                Fail                    JSON data does not match API response
            END
        END
    END
