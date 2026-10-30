# gitops-infra — платформа стенда

Каждая папка `components/<name>/` превращается в Argo CD Application `<name>` через ApplicationSet
[`platform`](https://github.com/PonamaryovMV/infra/blob/main/argocd/appsets/platform.yaml):

```
components/<name>/
├── component.yaml   # namespace + Helm-чарт (repoURL, name, version)
└── values.yaml      # values этого чарта
```

| Компонент | Чарт | Зачем |
|---|---|---|
| `traefik` | traefik/traefik `42.2.0` (v3.7) | вход на стенд: http://argocd, http://kargo, http://jenkins, http://qa-at-&lt;сервис&gt;-&lt;окружение&gt; |
| `cert-manager` | jetstack/cert-manager `v1.21.3` | сертификаты для webhook'ов Kargo |
| `argo-rollouts` | argo/argo-rollouts `2.43.8` (v1.10.1) | контроллер AnalysisRun — на нём работает верификация Kargo (DAST) |
| `kargo` | oci ghcr.io/akuity/kargo-charts/kargo `1.12.5` | промоушен ФП dev → test → uat → prod |
| `jenkins` | jenkins/jenkins `5.10.5` (2.580.2) | BuildRelease, ExcludeService, DAST — джобы JCasC из [jenkins](https://github.com/PonamaryovMV/jenkins) |

Добавить компонент = создать папку с этими двумя файлами и закоммитить.
Обновить = поменять `version` в `component.yaml`.

## Общий чарт main

`charts/main` — аналог корпоративного чарта `main`: образ
`<container.registry>/<global.automated_system>-<global.functional_system>-<global.appname>-<компонент>:<container.version>`,
на каждый компонент Deployment + Service, компонент с `ingress: true` публикуется как `<АС>-<ФП>-<сервис>-<окружение>`.
Workflow **publish-chart** проверяет чарт (`helm lint`, `helm template`) и публикует его в `oci://ghcr.io/ponamaryovmv/charts`.

## Kargo

- UI: http://kargo (ingress Traefik, TLS выключен — стенд). Логин `admin` / `123`.
- Секрет `kargo/kargo-api` и доступы на запись в `gitops-main` / `gitops-prod` создаёт `scripts/windows/up.ps1`.
- `minReconciliationInterval: 30s` — Warehouse видит новые коммиты за полминуты.

## Jenkins

- UI: http://jenkins, `admin` / `123`.
- Пользователь `kargo` (пароль — секрет `jenkins-kargo`): им Kargo запускает DAST.
- Джобы `qa-at/BuildRelease`, `qa-at/ExcludeService`, `qa-at/DAST` описаны в `values.yaml` (Job DSL), Jenkinsfile'ы — в репозитории `jenkins`.
