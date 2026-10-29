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
| `cert-manager` | jetstack/cert-manager `v1.21.3` | сертификаты для webhook'ов Kargo |
| `argo-rollouts` | argo/argo-rollouts `2.43.8` (v1.10.1) | canary приложений и анализ для верификации Kargo |
| `kargo` | oci ghcr.io/akuity/kargo-charts/kargo `1.12.5` | промоушены dev → stage → prod |
| `jenkins` | jenkins/jenkins `5.10.5` (2.580.2) | CI: тесты + Quality Gate (эмуляция SCA), джоба из [jenkins](https://github.com/PonamaryovMV/jenkins) через JCasC |

Добавить компонент = создать папку с этими двумя файлами и закоммитить.
Обновить = поменять `version` в `component.yaml`.

## Kargo

- UI/API: http://localhost:8081 (NodePort 30081, TLS выключен — стенд).
- Секрет `kargo/kargo-api` (bcrypt-хэш пароля admin + ключ подписи токенов) создаёт `scripts/up.sh`,
  в git его нет.
- Доступ на запись в GitHub — секрет `kargo-shared-resources/github-creds` (тоже из `up.sh`),
  общий для всех Kargo-проектов.
- `minReconciliationInterval: 30s` — Warehouse видит новые теги за полминуты (по умолчанию 5 минут).
