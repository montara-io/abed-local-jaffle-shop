{% test unique_tolerance(
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
    {{ column_name }} IN (
        SELECT
            {{ column_name }}
        FROM
            {{ model }}
        GROUP BY
            {{ column_name }}
        HAVING
            COUNT(*) > 1
    )
{% else %}
    WITH duplicate_percentage AS (
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
            {{ column_name }} IN (
                SELECT
                    {{ column_name }}
                FROM
                    {{ model }}
                GROUP BY
                    {{ column_name }}
                HAVING
                    COUNT(*) > 1
            )
    )
SELECT
    *
FROM
    {{ model }}
WHERE
    {{ column_name }} IN (
        SELECT
            {{ column_name }}
        FROM
            {{ model }}
        GROUP BY
            {{ column_name }}
        HAVING
            COUNT(*) > 1
    )
    AND (
        SELECT
            percentage
        FROM
            duplicate_percentage
    ) > {{ tolerance }}
{% endif %}

{% endtest %}
