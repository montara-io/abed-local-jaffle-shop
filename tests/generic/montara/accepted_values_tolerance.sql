{% test accepted_values_tolerance(
    model,
    column_name,
    tolerance,
    value
) %}
{% if tolerance == 0 %}
SELECT
    *
FROM
    {{ model }}
WHERE
    {{ column_name }} NOT IN (
        '{{ value | join("',
        '") }}'
    )
{% else %}
    WITH unaccepted_percentage AS (
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
            {{ column_name }} NOT IN (
                '{{ value | join("',
                '") }}'
            )
    )
SELECT
    *
FROM
    {{ model }}
WHERE
    {{ column_name }} NOT IN (
        '{{ value | join("',
        '") }}'
    )
    AND (
        SELECT
            percentage
        FROM
            unaccepted_percentage
    ) > {{ tolerance }}
{% endif %}

{% endtest %}
