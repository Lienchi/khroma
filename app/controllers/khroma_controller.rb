class KhromaController < ApplicationController
  before_action :set_category_list, only: [:index ,:pop_choices]

  def index
    @categories_init = []
    for i in 0...@category_list.length do
      for j in 0...@category_list[i].length
        type_names = []
        type_names << @category_list[i][j][:name]          
      end
      @categories_init[i] = Category.where(gender_id: 1, name: type_names)
    end
  end

  def navbar
    categories = Category.includes(:types).where(gender_id: params[:id])

    render json: {
      html: render_to_string(partial: 'shared/navbar', locals: {categories: categories})
    }
  end

  def match

    @matches = Match.new(params[:up_type_id], params[:up_hue_level], params[:down_type_id], params[:down_hue_level])
    @matches.puts_attributes_count

    render json: {
      productsMatchHtml: render_to_string(partial: 'shared/match_result', locals: {principles: @matches.principles,
        top_colors: @matches.top_colors, bottom_colors: @matches.bottom_colors, optional_colors: @matches.optional_colors,
        top_products: @matches.top_products, bottom_products: @matches.bottom_products})
    }

    # no_params = {'up_type' => params[:up_type_id] == '',
    #              'up_hue_level' => params[:up_hue_level] == '',
    #              'down_type' => params[:down_type_id] == '',
    #              'down_hue_level' => params[:down_hue_level] == ''
    #             }

    # # 至少要給一個category的type+hue_level才能進行配對
    # if (!no_params['up_type'] && !no_params['up_hue_level']) ||
    #    (!no_params['down_type'] && !no_params['down_hue_level'])
    #   # 參數足夠，可以進行配對

    #   # puts 是方便觀察用的，可以刪掉
    #   # puts "up_type_id: #{params[:up_type_id]}"
    #   # puts "up_hue_level: #{params[:up_hue_level]}"
    #   # puts "down_type_id: #{params[:down_type_id]}"
    #   # puts "down_hue_level: #{params[:down_hue_level]}"
    #   matches = []
      
    #   if no_params['up_hue_level'] || no_params['down_hue_level']  # 有個hue_level沒給 => 提供使用者顏色、該顏色衣服以及配色法則

    #     # 找出hue_level_id符合的PrincipleColor資料, 可得match_hue1, match_hue2以及principle_id
    #     # 可用來提供使用者顏色、該顏色衣服以及配色法則
    #     if no_params['up_hue_level']  # 
    #       hue_level = params[:down_hue_level].to_i
    #       type_with_hue_level = params[:down_type_id]
    #       type_without_hue_level = no_params['up_type'] ? -1 : params[:up_type_id]
    #     else
    #       hue_level = params[:up_hue_level].to_i 
    #       type_with_hue_level = params[:up_type_id]
    #       type_without_hue_level = no_params['down_type'] ? -1 : params[:down_type_id]         
    #     end
    #     hue_level = no_params['up_hue_level'] ? params[:down_hue_level].to_i : params[:up_hue_level].to_i
    #     @principle_colors = PrincipleColor.where(hue_level_id: hue_level)  # 從提供的hue_level找到多筆對應PrincipleColor
    #     @principle_colors.each do |principle_color| 
          
    #       result = []
    #       # 1.配色法則 -------------
    #       # result_arr[0]: 配色法則
    #       #  - result_arr[0][0]: 配色法則的名稱
    #       #  - result_arr[0][1]: 配色法則的圖片  # 圖片製作中...
    #       result.push([principle_color.principle.name, principle_color.principle.image])
          
    #       # 2.符合法則的配色顏色 -------------
    #       # result_arr[1] = color_names: 符合法則的配色顏色
    #       #  - result_arr[1][0] = 上半身的顏色
    #       #  - result_arr[1][1] = 下半身的顏色
    #       #  - result_arr[1][2] = 額外可選的顏色
    #       #  - result_arr[1][3] = 上半身顏色的hex
    #       #  - result_arr[1][4] = 下半身顏色的hex
    #       #  - result_arr[1][5] = 額外可選顏色的hex

    #       color_names = []
    #       top_hue_level = no_params['up_hue_level'] ? principle_color.match1_hue_level : HueLevel.find(hue_level)
    #       bottom_hue_level = no_params['up_hue_level'] ? HueLevel.find(hue_level) : principle_color.match1_hue_level
    #       optional_hlv_name = principle_color.option1_hue_level.nil? ? nil : principle_color.option1_hue_level.name
    #       optional_hlv_hex = principle_color.option1_hue_level.nil? ? nil : principle_color.option1_hue_level.hex
    #       # TODO: 還要再加option2_hue_level

    #       color_names.push(top_hue_level.name)          # 上半身的顏色
    #       color_names.push(bottom_hue_level.name)   # 下半身的顏色
    #       color_names.push(optional_hlv_name)          # 額外可選的顏色
    #       color_names.push(top_hue_level.hex)       # 上半身顏色的hex
    #       color_names.push(bottom_hue_level.hex)    # 下半身顏色的hex
    #       color_names.push(optional_hlv_hex)  # 下半身顏色的hex
    #       result.push(color_names)
          
    #       # 3.配色顏色的衣服 -------------
    #       # result_arr[2] = products: 配色顏色的衣服
    #       #  - result_arr[2][0] = 上半身的衣服
    #       #  - result_arr[2][1] = 下半身的衣服
    #       products = []
    #       product_of_given_color = Type.find(type_with_hue_level).products.joins(:color).where('colors.hue_level_id = ?', hue_level)
    #       if type_without_hue_level == -1  # 沒給type -> 從category找products
    #         # 從有給type的category反推找出沒給的category
    #         category_id = Type.find(type_with_hue_level).category.id  # 有給type的category
    #         category_id = category_id.even? ? (category_id - 1) : (category_id + 1)  # 有給type的category.id是偶數 -> 沒給的是奇數
    #         product_of_match_color = Category.find(category_id).products.joins(:color).where('colors.hue_level_id = ?', principle_color.match1_hue_level.id).limit(10)
    #       else  # 有給type
    #         product_of_match_color = Type.find(type_without_hue_level).products.joins(:color).where('colors.hue_level_id = ?', principle_color.match1_hue_level.id).limit(10)             
    #       end
    #       if no_params['up_hue_level']
    #         products.push(product_of_match_color)  # 上半身的衣服
    #         products.push(product_of_given_color)  # 下半身的衣服
    #       else
    #         products.push(product_of_given_color)  # 上半身的衣服
    #         products.push(product_of_match_color)  # 下半身的衣服
    #       end
    #       result.push(products)
    #       matches.push(result)           
    #     end
    #     # matches[i][0][0]: 配色法則名稱
    #     # matches[i][0][1]: 配色法則圖片
    #     # matches[i][1][0]: 上半身的顏色
    #     # matches[i][1][1]: 下半身的顏色
    #     # matches[i][1][2]: 額外可選的顏色
    #     # matches[i][1][3]: 上半身顏色的hex
    #     # matches[i][1][4]: 下半身顏色的hex
    #     # matches[i][1][5]: 額外可選顏色的hex
    #     # matches[i][2][0]: 上半身的衣服
    #     # matches[i][2][1]: 下半身的衣服
    #     render json: {
    #       productsMatchHtml: render_to_string(partial: 'shared/match_result', locals: {matches: matches})
    #     }

    #   else  # 兩個hue_level都有

    #     # 找出hue_level_id符合的PrincipleColor資料, 可得match_hue1, match_hue2以及principle_id
    #     # 依照狀況提供使用者顏色、該顏色衣服以及配色法則（或是提示沒有符合的法則）
                
    #     # rel_table參考資料: https://stackoverflow.com/questions/3639656/activerecord-or-query
    #     # @principle_colors查詢說明:
    #     #   第一個where: 找hue_level_id符合上衣顏色的PrincipleColor
    #     #   第二個where: 看hue_match1或是hue_match2是否等於褲子顏色
    #     #   得到結果: 包含上衣和褲子顏色的PrincipleColor資料，可從principle_color.principle得知這兩個衣服符合什麼配色法則

    #     pc = PrincipleColor.arel_table
    #     @principle_colors = PrincipleColor.where(hue_level_id: params[:up_hue_level]).where(
    #       pc[:hue_match1].eq(params[:down_hue_level]).or(pc[:hue_option1].eq(params[:down_hue_level])))

    #     if @principle_colors.count == 0  # 沒有符合的配色法則
    #       result = []
    #       # 1.配色法則 -------------
    #       # result_arr[0]: 配色法則
    #       #  - result_arr[0][0]: 配色法則的名稱
    #       #  - result_arr[0][1]: 配色法則的圖片  # 圖片製作中...
    #       result.push(['沒有符合的配色法則', ''])

    #       # 2.符合法則的配色顏色 => 用使用者給的顏色-------------
    #       # result_arr[1] = color_names: 符合法則的配色顏色
    #       #  - result_arr[1][0] = 上半身的顏色
    #       #  - result_arr[1][1] = 下半身的顏色
    #       #  - result_arr[1][2] = nil(沒有額外可選的顏色)
    #       #  - result_arr[1][3] = 上半身顏色的hex
    #       #  - result_arr[1][4] = 下半身顏色的hex
    #       #  - result_arr[1][5] = nil(沒額外可選顏色的hex)
    #       top_hue_level      = HueLevel.find(params[:up_hue_level])
    #       bottom_hue_level   = HueLevel.find(params[:down_hue_level])
    #       color_names = [top_hue_level.name, bottom_hue_level.name, nil,
    #                      top_hue_level.hex, bottom_hue_level.hex, nil]
    #       result.push(color_names)
          
    #       # 3.配色顏色的衣服 -------------
    #       # result_arr[2] = products: 配色顏色的衣服
    #       #  - result_arr[2][0] = 上半身的衣服
    #       #  - result_arr[2][1] = 下半身的衣服
    #       products = []
    #       top_products    = Type.find(params[:up_type_id]).products.joins(:color).where('colors.hue_level_id = ?', params[:up_hue_level]).limit(10)
    #       bottom_products = Type.find(params[:down_type_id]).products.joins(:color).where('colors.hue_level_id = ?', params[:down_hue_level]).limit(10)
    #       products = [top_products, bottom_products]
    #       result.push(products)

    #       matches.push(result) 
              
    #       render json: {
    #         productsMatchHtml: render_to_string(partial: 'shared/match_result', locals: {matches: matches})
    #       }

    #     else  # 有符合的法則

    #       @principle_colors.each_with_index do |principle_color, i|
    #         # TODO: 還要再加option2_hue_level
    #         if principle_color.option1_hue_level.nil?
    #           second_option = [nil, nil]
    #         else
    #           second_option = principle_color.match1_hue_level.id == params[:down_hue_level].to_i ? principle_color.option1_hue_level : principle_color.match1_hue_level
    #           second_option = [second_option.name, second_option.hex]
    #         end 

    #         result = []
    #         # 1.配色法則 -------------
    #         # result_arr[0]: 配色法則
    #         #  - result_arr[0][0]: 配色法則的名稱
    #         #  - result_arr[0][1]: 配色法則的圖片  # 圖片製作中...
    #         result.push([principle_color.principle.name, principle_color.principle.image])

    #         # 2.符合法則的配色顏色 -------------
    #         # result_arr[1] = color_names: 符合法則的配色顏色
    #         #  - result_arr[1][0] = 上半身的顏色
    #         #  - result_arr[1][1] = 下半身的顏色
    #         #  - result_arr[1][2] = 額外可選的顏色
    #         #  - result_arr[1][3] = 上半身顏色的hex
    #         #  - result_arr[1][4] = 下半身顏色的hex
    #         #  - result_arr[1][5] = 額外可選顏色的hex

    #         top_hue_level      = HueLevel.find(params[:up_hue_level])
    #         bottom_hue_level   = HueLevel.find(params[:down_hue_level])

    #         color_names = []
    #         color_names.push(top_hue_level.name)  # 上半身的顏色
    #         color_names.push(bottom_hue_level.name)  # 下半身的顏色 
    #         color_names.push(second_option[0])  # 額外可選的顏色
    #         color_names.push(top_hue_level.hex)  # 上半身的顏色
    #         color_names.push(bottom_hue_level.hex)  # 下半身的顏色 
    #         color_names.push(second_option[1])  # 額外可選的顏色
    #         result.push(color_names)
            
    #         # 3.配色顏色的衣服 -------------
    #         # result_arr[2] = products: 配色顏色的衣服
    #         #  - result_arr[2][0] = 上半身的衣服
    #         #  - result_arr[2][1] = 下半身的衣服
    #         products = []
    #         product_top = Type.find(params[:up_type_id]).products.joins(:color).where('colors.hue_level_id = ?', params[:up_hue_level]).limit(10)
    #         product_of_bottom = Type.find(params[:down_type_id]).products.joins(:color).where('colors.hue_level_id = ?', params[:down_hue_level]).limit(10)
    #         result.push([product_top, product_of_bottom])

    #         matches.push(result)  

    #         render json: {
    #           productsMatchHtml: render_to_string(partial: 'shared/match_result', locals: {matches: matches})
    #         }         
    #       end
    #     end
    #   end
    # else
    #   # ---- TODO ----------------------------------        
    #   # 使用者給的參數不足，無法配色...
    #   # 給提示訊息告訴使用者至少要給一個category的type+hue_level & 另一個category的type才能進行配對
    #   # ---- END TODO -------------------------------
    # end

  end

  def pop_choices
    categories = []
    for i in 0...@category_list.length do
      for j in 0...@category_list[i].length
        type_names = []
        type_names << @category_list[i][j][:name]          
      end
      categories[i] = Category.where(gender_id: params[:gender_id], name: type_names)
    end

    render json:{
      typesUpHtml: render_to_string(partial: 'shared/pop_choices', locals: {categories: categories[0]}),
      typesDownHtml: render_to_string(partial: 'shared/pop_choices', locals: {categories: categories[1]})
    }
  end

  private

  def set_category_list
    @category_list = [ [{name: '上衣類'}], [{name: '下身類'}] ]
  end


end
