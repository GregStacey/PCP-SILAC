
%% Initialize.
% These are hacky fixes.

precision_write_out_counter = pri;
Precision_values = desiredPrecision * 100;


%% Write out True interaction and summary lists for precision.
%Generate headers to write out
size_interaction_replicates=size(interactions_prep_replicate);

%Create header for the list of replicate and interactions observed
for column_counter=1:size_interaction_replicates(2)
  Column_name1{column_counter}=strcat('Interaction Replicate_',mat2str(column_counter));
end

%Create header
Column_header1=repmat('%s,', 1, size_interaction_replicates(2)+7);

Interaction_pre_rep_name=strcat(datadir3,'Interactions_across_replicate_',mat2str(Precision_values(precision_write_out_counter)),'pc.csv');
Inter_pre_rep = fopen(Interaction_pre_rep_name,'w');
fprintf (Inter_pre_rep,[Column_header1, '\n'],... %header for output
  'Protein interaction','Center A','Center B',...
  'Total number of observation of interaction',...
  'Total number of replicates interaction observed in',Column_name1{:},...
  'Both proteins in Corum', 'Interaction in Corum'); %Write Header
for write_out_loop2=1:Total_unique_interactions
  fprintf(Inter_pre_rep,'%s,',interaction_final.unique_interactions{write_out_loop2,1});
  fprintf(Inter_pre_rep,'%6.3f,',interaction_final.CenterA{write_out_loop2,1});
  fprintf(Inter_pre_rep,'%6.3f,',interaction_final.CenterB{write_out_loop2,1});
  fprintf(Inter_pre_rep,'%6f,',number_observation_pre_interaction(write_out_loop2,1));
  fprintf(Inter_pre_rep,'%6f,', number_unique_interaction(write_out_loop2,1));
  fprintf(Inter_pre_rep,'%6f,', interactions_prep_replicate(write_out_loop2,1:end));
  fprintf(Inter_pre_rep,'%6f,',interaction_final.proteinInCorum{write_out_loop2,1});
  fprintf(Inter_pre_rep,'%6f,',interaction_final.interactionInCorum{write_out_loop2,1});
  fprintf(Inter_pre_rep,',\n');
end
fclose(Inter_pre_rep);

Final_Results_name=strcat(datadir3,'Summary_Results_',mat2str(Precision_values(precision_write_out_counter)),'pc_replicate.csv');
fid_final= fopen(Final_Results_name,'wt'); % create the summary file of the interaction output
fprintf (fid_final,'%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',... %header for OutputGaus output
  'Recall (non redundant)', 'Precision (non redundant)', 'TPR (non redundant)', 'FPR (non redundant)',...
  'Precision (redundant)','Total number of interactions (redundant across replicate)',...
  'Unique number of interactions (Nonredundant within replicate)',...
  'Total Unique interactions (Nonredundant across replicate)',...
  'Number non-redundant interactions' ); %Write Header
fprintf (fid_final,'%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,\n',...
  final_Recall, final_Precision, final_TPR,...
  final_FPR, Precent_precision_NR, total_observation,...
  total_unique_observation, Total_unique_interactions, length_unique_inter);
fprintf (fid_final,',\n');
fclose(fid_final);


[~,scoreRank] = sort(nanmean(interaction_final.score,2));
Final_list_Interactionsname=strcat(datadir3,'Final_Interactions_list_',mat2str(Precision_values(precision_write_out_counter)),'_precision.csv');
fid_final_1 = fopen(Final_list_Interactionsname,'w');
fprintf (fid_final_1,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',...
  'Unique interactions','Protein A','Protein B','Center A',...
  'Center B','Replicate','Delta Height', 'Delta Center','Delta Width',...
  'Delta EucDist', 'Both proteins in Corum', 'Interaction in Corum','Interaction score',...
  'Interaction rank (1 = best interaction)'); %Write Header
for ix=1:Total_unique_interactions
  fprintf(fid_final_1,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%d,%d,%s,%6.4f,\n',...
    interaction_final.unique_interactions{ix},...
    interaction_final.proteinA{ix},...
    interaction_final.proteinB{ix},...
    interaction_final.centerA_formated{ix},...
    interaction_final.centerB_formated{ix},...
    interaction_final.Replicates_formated{ix},...
    interaction_final.DeltaHeight_formated{ix},...
    interaction_final.DeltaCenter_formated {ix},...
    interaction_final.Deltawidth_formated{ix},...
    interaction_final.DeltaEuc_formated{ix},...
    interaction_final.proteinInCorum{ix},...
    interaction_final.interactionInCorum{ix},...
    interaction_final.scores_formated{ix},...
    scoreRank(ix));
end
fclose(fid_final_1);


Final_Results_name=strcat(datadir3,'Global_Precision_across_replicates_',mat2str(Precision_values(precision_write_out_counter)),'pc.csv');
fid_final2= fopen(Final_Results_name,'wt'); % create the summary file of the interaction output
fprintf (fid_final2,'%s,%s,%s,%s,%s,\n',... %header for OutputGaus output
  'Number of replicates interaction observed in',...
  'Proteins in corum but no interaction(FP-non redundent interaction)',...
  'Interaction in corum (TP-non redundent interaction)',...
  'Total interactions not in corum (non redundent interaction)',...
  'Precision % (non redundent interaction)'); %Write Header
for precision_counter=1:(number_of_replicates*number_of_channels)
  fprintf (fid_final2,'%6f,%6f,%6f,%6f,%6f,\n',...
    precision_counter, Precision_array(precision_counter,1),...
    Precision_array(precision_counter,2),...
    Precision_array(precision_counter,3),...
    Precent_precision_R(precision_counter));
end
fclose(fid_final2);


if ~isempty(treatment_replicates)
  %Write out treatment specific interactions
  Final_list_Interactionsname=strcat(datadir3,'Final_Treatment_specific_interactions_list_',mat2str(Precision_values(precision_write_out_counter)),'_precision.csv');
  fid_final_3 = fopen(Final_list_Interactionsname,'w');
  fprintf (fid_final_3,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',...
    'Unique interactions','Protein A','Protein B','Center A',...
    'Center B','Replicate','Delta Height', 'Delta Center','Delta Width',...
    'Delta EucDist', 'Both proteins in Corum', 'Interaction in Corum'); %Write Header
  for xii=1:treament_specific_interactionsnum
    fprintf(fid_final_3,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',...
      treatment_specific.unique_interactions{xii,1},...
      treatment_specific.proteinA{xii,1},...
      treatment_specific.proteinB{xii,1},...
      treatment_specific.centerA_formated{xii,1},...
      treatment_specific.centerB_formated{xii,1},...
      treatment_specific.Replicates_formated{xii,1},...
      treatment_specific.DeltaHeight_formated{xii,1},...
      treatment_specific.DeltaCenter_formated {xii,1},...
      treatment_specific.Deltawidth_formated{xii,1},...
      treatment_specific.DeltaEuc_formated{xii,1},...
      treatment_specific.proteinInCorum{xii,1},...
      treatment_specific.interactionInCorum{xii,1});
  end
  fclose(fid_final_3);
  
  
  %Write out treatment specific interactions
  Final_list_Interactionsname=strcat(datadir3,'Final_Untreatment_specific_interactions_list_',mat2str(Precision_values(precision_write_out_counter)),'_precision.csv');
  fid_final_4 = fopen(Final_list_Interactionsname,'w');
  fprintf (fid_final_4,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',...
    'Unique interactions','Protein A','Protein B','Center A',...
    'Center B','Replicate','Delta Height', 'Delta Center','Delta Width',...
    'Delta EucDist', 'Both proteins in Corum', 'Interaction in Corum'); %Write Header
  for xiii=1:untreament_specific_interactionsnum
    fprintf(fid_final_4,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',...
      untreatment_specific.unique_interactions{xiii,1},...
      untreatment_specific.proteinA{xiii,1},...
      untreatment_specific.proteinB{xiii,1},...
      untreatment_specific.centerA_formated{xiii,1},...
      untreatment_specific.centerB_formated{xiii,1},...
      untreatment_specific.Replicates_formated{xiii,1},...
      untreatment_specific.DeltaHeight_formated{xiii,1},...
      untreatment_specific.DeltaCenter_formated {xiii,1},...
      untreatment_specific.Deltawidth_formated{xiii,1},...
      untreatment_specific.DeltaEuc_formated{xiii,1},...
      untreatment_specific.proteinInCorum{xiii,1},...
      untreatment_specific.interactionInCorum{xiii,1});
  end
  fclose(fid_final_4);
end