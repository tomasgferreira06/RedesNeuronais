function [] = cbr()

    similarity_threshold = 0.90;
    file_path = 'goiaba.csv'; 

    
    formatSpec = '%f%f%f%f%f%f%f%f%f%f%f';

    
    case_library = readtable(file_path, ...
    'Delimiter', ';', ...
    'Format', formatSpec);

    % Encontre as linhas onde o valor da coluna stroke é NaN
    missing_stroke_indexes = find(isnan(case_library.stroke));


    if isempty(missing_stroke_indexes)
           error('Não foram encontrados valores NaN na coluna do stroke.');
    end

    % Percorre todas as linhas com stroke NaN
    for idx = missing_stroke_indexes'
        
        % Configura new_case com os valores da linha encontrada
        new_case.gender = case_library.gender(idx);
        new_case.age = case_library.age(idx);
        new_case.hypertension = case_library.hypertension(idx);
        new_case.heart_disease = case_library.heart_disease(idx);
        new_case.ever_married = case_library.ever_married(idx);
        new_case.Residence_type = case_library.Residence_type(idx);
        new_case.avg_glucose_level = case_library.avg_glucose_level(idx);
        new_case.bmi = case_library.bmi(idx);
        new_case.smoking_status = case_library.smoking_status(idx);

        fprintf('\nStarting retrieve phase for index %d...\n\n', idx);

        % Chama a função retrieve para o new_case configurado
        [retrieved_indexes, similarities, updated_case] = retrieve(case_library, new_case, similarity_threshold);
    
        % Ignora o caso próprio (similaridade de 1) e encontra o maior abaixo de 1
        valid_similarities = similarities < 1;
        filtered_similarities = similarities(valid_similarities);
        filtered_indexes = retrieved_indexes(valid_similarities);

        % Encontra o índice com a maior similaridade válida
        if ~isempty(filtered_similarities)
            [max_similarity, max_index] = max(filtered_similarities);

            % Verifica se a maior similaridade é maior que o threshold
            if max_similarity > similarity_threshold
                % Selecionar o valor de stroke do caso mais semelhante
                similar_case_stroke = case_library.stroke(filtered_indexes(max_index));
                % Atualiza o valor de stroke na linha original
                case_library.stroke(idx) = similar_case_stroke;

                fprintf('\nUpdated stroke for index %d with value from most similar case below similarity 1.\n\n', idx);
            else
                fprintf('No cases retrieved with similarity above %f for index %d.\n', similarity_threshold, idx);
            end
        else
            fprintf('No valid cases found below similarity of 1 for index %d.\n', idx);
        end
    end

    % Guardar a tabela
    writetable(case_library, file_path);
    fprintf('Updated CSV file saved.\n');
end
