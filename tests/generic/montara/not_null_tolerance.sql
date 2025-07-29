{% test not_null_tolerance(
    model,
    column_name,
    tolerance
) %}
{% if tolerance == 0 %}
SELECT
    *
FROM
    {{ model }}
WHERE
    {{ column_name }} IS NULL
{% else %}
    WITH null_percentage AS (
        SELECT
            (COUNT(*) * 100.0) / (
                SELECT
                    COUNT(*)
                FROM
                    {{ model }}
            ) AS percentage
        FROM
            {{ model }}
        WHERE
            {{ column_name }} IS NULL
    )
SELECT
    *
FROM
    {{ model }}
WHERE
    {{ column_name }} IS NULL
    AND (
        SELECT
            percentage
        FROM
            null_percentage
    ) > {{ tolerance }}
{% endif %}

{% endtest %}
