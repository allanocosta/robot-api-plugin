*** Settings ***
Documentation       Cenários para testar os endpoints da rota Log Acesso

Resource            ${CURDIR}/../resources/activities.resource

Suite Setup         Conectar API

Test Tags           FakeRestApi    task:retry(1)    Activities


*** Test Cases ***
Operation Activities - Deve Obter Todas As Atividades Cadastradas
    [Documentation]    Deve obter o cadastro de todas as atividades cadastradas no banco de dados
    [Tags]                  GetActivities           SmokeTest

    ${DATA}                 Obter Fixtures          activities              get

    GET Activities          ${DATA}[all]
    Response Validar JSON Com API                   ${DATA}[all]
