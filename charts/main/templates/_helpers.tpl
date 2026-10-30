{{/* <АС>-<ФП>-<сервис> */}}
{{- define "main.prefix" -}}
{{ required "global.automated_system обязателен" .Values.global.automated_system }}-{{ required "global.functional_system обязателен" .Values.global.functional_system }}-{{ required "global.appname обязателен" .Values.global.appname }}
{{- end -}}

{{/* <АС>-<ФП>-<сервис>-<окружение> — имя хоста в ingress */}}
{{- define "main.host" -}}
{{ include "main.prefix" . }}-{{ required "global.environment обязателен" .Values.global.environment }}
{{- end -}}

{{- define "main.labels" -}}
app.kubernetes.io/part-of: {{ include "main.prefix" .root }}
app.kubernetes.io/name: {{ include "main.prefix" .root }}-{{ .component.name }}
app.kubernetes.io/version: {{ .root.Values.container.version | quote }}
stand/environment: {{ .root.Values.global.environment | quote }}
{{- end -}}

{{- define "main.selector" -}}
app.kubernetes.io/name: {{ include "main.prefix" .root }}-{{ .component.name }}
{{- end -}}
