function [retrieved_indexes, similarities, new_case] = retrieve(case_library, new_case, threshold)
    % Inicialize as variáveis de saída
    retrieved_indexes = [];
    similarities = [];
    %teste = 0;
    
    % Lista de atributos para calcular a similaridade
    attributes = {'gender', 'age', 'hypertension', 'heart_disease', 'ever_married', 'Residence_type', 'avg_glucose_level', 'bmi', 'smoking_status'};
    
    % Para cada caso na biblioteca de casos
    for i = 1:size(case_library, 1)
        % Calcule a similaridade entre o novo caso e o caso atual
        similarity = calculate_similarity(case_library(i, :), new_case, attributes);
        
        % Se a similaridade for válida e maior ou igual ao threshold
        if ~isnan(similarity) && similarity >= threshold
            similarities = [similarities, similarity];
            retrieved_indexes = [retrieved_indexes; i];
        end


    end

    if isempty(retrieved_indexes)
        fprintf('Warning: No cases retrieved with similarity >= %.2f\n', threshold);
    else
        fprintf('Successfully retrieved %d cases with similarity >= %.2f\n', length(retrieved_indexes), threshold);
    end
    
    fprintf('Retrieve phase completed.\n');
end


function similarity = calculate_similarity(existing_case, new_case, attributes)
   
    similarity = 0;
    
   weighting_factors = [3, 5, 3, 3, 1, 1, 5, 2, 3]; % Correspondente aos atributos
    
   
    for i = 1:numel(attributes)
        attribute = attributes{i};
        attribute_weight = weighting_factors(i);
        
        % Calcular similaridade para cada tipo de atributo
        switch attribute
            case 'gender'
                attribute_similarity = calculate_categorical_similarity(existing_case.(attribute), new_case.(attribute));
            case 'age'
                attribute_similarity = calculate_age_similarity(existing_case.(attribute), new_case.(attribute));
            case 'avg_glucose_level'
                attribute_similarity = calculate_avg_glucose_level_similarity(existing_case.(attribute), new_case.(attribute));
            case 'bmi'
                attribute_similarity = calculate_bmi_similarity(existing_case.(attribute), new_case.(attribute));
            case {'hypertension', 'heart_disease', 'ever_married', 'Residence_type'}
                attribute_similarity = calculate_categorical_similarity(existing_case.(attribute), new_case.(attribute));
            case 'smoking_status'
                attribute_similarity = calculate_smoking_status_similarity(existing_case.(attribute), new_case.(attribute));
            otherwise
                error('Attribute %s not supported.', attribute);
        end
        
        % Aplicar o peso ao valor da similaridade do atributo
        similarity = similarity + attribute_similarity * attribute_weight;
    end
    
    % Normalizar pela soma dos pesos para manter a similaridade entre 0 e 1
    similarity = similarity / sum(weighting_factors);
end


function similarity = calculate_categorical_similarity(value1, value2)
    if value1 == value2
        similarity = 1; % Iguais
    else
        similarity = 0; % Diferentes
    end
end


function similarity = calculate_age_similarity(value1, value2) 

    min_value = 0; % Valor mínimo possível
    max_value = 90; % Valor máximo possível
    
    % Distância entre valores
    distance = abs(value1 - value2);
    
    % Calcular a similaridade como 1 menos a proporção da distância sobre o intervalo
    similarity = 1 - (distance / (max_value - min_value));
    
    % Garantir que a similaridade está entre 0 e 1
    similarity = max(0, min(1, similarity));
end

function similarity = calculate_avg_glucose_level_similarity(value1, value2) 

    min_value = 0; % Valor mínimo possível
    max_value = 275; % Valor máximo possível
    
    % Distância entre valores
    distance = abs(value1 - value2);
    
    % Calcule a similaridade como 1 menos a proporção da distância sobre o intervalo
    similarity = 1 - (distance / (max_value - min_value));
    
    % Assegure-se de que a similaridade está entre 0 e 1
    similarity = max(0, min(1, similarity));
end

function similarity = calculate_bmi_similarity(value1, value2) 
    
    min_value = 0; 
    max_value = 60; 
    
    % Distância entre valores
    distance = abs(value1 - value2);
    
    % Calcule a similaridade como 1 menos a proporção da distância sobre o intervalo
    similarity = 1 - (distance / (max_value - min_value));
    
    % Assegure-se de que a similaridade está entre 0 e 1
    similarity = max(0, min(1, similarity));
end

function similarity = calculate_smoking_status_similarity(value1, value2)

    if value1 == value2 
        similarity = 1; 
    elseif (value1 == 1 && value2 == 2) || (value1 == 2 && value2 == 1)
        similarity = 0.75;
    else
        similarity = 0; 
    end
end
