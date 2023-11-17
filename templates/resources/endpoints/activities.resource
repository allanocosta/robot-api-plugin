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
