function [spectral_data,c] = spectral_data( bits, data )
%Table 4.56 – Syntax of spectral_data()

%Init
c = 0;
num_window_groups = data.ics_info.num_window_groups;
max_sfb = data.ics_info.max_sfb;
sect_sfb_offset = data.ics_info.sect_sfb_offset;
codebooks = data.codebooks;
spectral_data = cell(1,data.ics_info.num_window_groups);
for g=1:data.ics_info.num_window_groups
    spectral_data{g} = zeros(1,data.ics_info.window_group_length(g)*data.ics_info.window_length);
end
hcb_tab = hcb_tables();
hcb_dim = [4 4 4 4 2 2 2 2 2 2 2];
hcb_sig = [1 1 0 0 1 1 0 0 0 0 0];

%Loop over window groups
for g=1:num_window_groups
    
    %Loop over scale factor bands
    for sfb=1:max_sfb

        %Decode spectral data for non-zero bands
        if 0<codebooks(g,sfb)&&codebooks(g,sfb)<=11
            
            %Init
            tab = hcb_tab{codebooks(g,sfb)};
            dim = hcb_dim(codebooks(g,sfb));
            sig = hcb_sig(codebooks(g,sfb));
            
            %Iterate over the blocks of length dim
            for k=sect_sfb_offset(g,sfb):dim:sect_sfb_offset(g,sfb+1)-1

                %Decode Codeword
                idx = 1;
                len = tab(idx,1);
                codeword = bits2int( bits(c+1:c+len) );
                c = c + len;
                while codeword~=tab(idx,2)
                    idx = idx + 1;
                    len2 = tab(idx,1) - len;
                    len = tab(idx,1);
                    if len2~=0
                        codeword2 = bits2int( bits(c+1:c+len2) );
                        c = c + len2;
                        codeword = codeword*2^len2 + codeword2;
                    end
                end
                
                %Convert to spectral data
                spectral_data{g}(k:k+dim-1) = tab(idx,3:3+dim-1);
                
                %Decode sign data if codebook is not signed
                if ~sig
                    for k2=1:dim
                        if spectral_data{g}(k+k2-1)
                            bit = bits(c+1);
                            c = c + 1;
                            if bit
                                spectral_data{g}(k+k2-1) = -spectral_data{g}(k+k2-1);
                            end
                        end
                    end
                end
                
                %Escape data if codebook==11
                if codebooks(g,sfb)==11
                    for k2=1:dim
                        if abs(spectral_data{g}(k+k2-1))==16
                            j = 4;
                            while 1
                                bit = bits(c+1);
                                c = c + 1;
                                if bit==0
                                    break;
                                else
                                    j = j + 1;
                                end
                            end
                            if j>16
                                codeword = bits2int( bits(c+1:c+j-16) );
                                c = c + j-16;
                                codeword2 = bits2int( bits(c+1:c+16) );
                                c = c + 16;
                                codeword = codeword*2^16 + codeword2;
                            else
                                codeword = bits2int( bits(c+1:c+j) );
                                c = c + j;
                            end
                            codeword = codeword + 2^j;
                            if spectral_data{g}(k+k2-1)>0
                                spectral_data{g}(k+k2-1) = codeword;
                            else
                                spectral_data{g}(k+k2-1) = -codeword;
                            end
                        end
                    end
                end
            end
        end
    end
end