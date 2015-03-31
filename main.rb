# 動作物件，含初始動作action_m
# 四個邊界動作bc_x_begin（x = 0）、bc_x_end（x = end）、bc_y_begin（y = 0）、bc_y_end（y = end）
class ActionM
  attr_accessor :action_m, :bc_x_begin, :bc_x_end, :bc_y_begin, :bc_y_end

  def initialize(oblique = 'on')
    if oblique == 'on'
      @action_m    = %w(U D L R UL UR DL DR)
    elsif oblique == 'off'
      @action_m    = %w(U D L R)
    end
    @bc_x_begin  = %w(L UL DL)
    @bc_x_end    = %w(R UR DR)
    @bc_y_begin  = %w(U UL UR)
    @bc_y_end    = %w(D DL DR)
  end
end

# 資料物件，含矩陣資料init_data_m、動作物件action（存放class ActionM）
# 兩個method，定義矩陣的起始位置(0,0)與最終（大）位置(i,j)
class InitData
  attr_accessor :init_data_m, :action

  def initialize(init_data_m, oblique = 'on')
    @init_data_m = init_data_m
    @action = ActionM.new(oblique)
  end

  def index_begin
    [0, 0]
  end

  def index_end
    i = @init_data_m.size - 1
    j = @init_data_m[0].size - 1
    [i, j]
  end
end

# init: :init_xy, :final_xy, :action, :final_array, :rank
class OutputData
  attr_accessor :init_xy, :final_xy, :action, :final_array, :rank

  def initialize
    @init_xy = Array.new(2)
    @final_xy = Array.new(2)
    @action = []
    @final_array = []
    @rank = 0
  end
end

# 主程式物件，內含四個屬性，四個method
# 屬性分別為初始矩陣init_array、動作次數times、輸出Hash am_n、am_n_add_one
# method後續詳述
class MainRun
  attr_reader :am_n

  def initialize(init_array)
    # @times = times
    # @dtimes = dtimes
    @am_n = {}
    # @am_n_add_one = {}
    @init_array = init_array
  end

  # 判斷矩陣元素是否在邊界上，並刪除不可能的動作
  def bc_check(input_array, index_x, index_y)
    if index_x == input_array.index_begin[0]
      input_array.action.action_m = input_array.action.action_m - input_array.action.bc_x_begin
    end
    if index_x == input_array.index_end[0]
      input_array.action.action_m = input_array.action.action_m - input_array.action.bc_x_end
    end
    if index_y == input_array.index_begin[1]
      input_array.action.action_m = input_array.action.action_m - input_array.action.bc_y_begin
    end
    if index_y == input_array.index_end[1]
      input_array.action.action_m = input_array.action.action_m - input_array.action.bc_y_end
    end
    input_array
  end

  # 去除上一步動作
  def up_move_check(input_array, last_action)
    if last_action == 'U'
      input_array.action.action_m = input_array.action.action_m - %w(D)
    end
    if last_action == 'D'
      input_array.action.action_m = input_array.action.action_m - %w(U)
    end
    if last_action == 'L'
      input_array.action.action_m = input_array.action.action_m - %w(R)
    end
    if last_action == 'R'
      input_array.action.action_m = input_array.action.action_m - %w(L)
    end
    if last_action == 'UL'
      input_array.action.action_m = input_array.action.action_m - %w(DR)
    end
    if last_action == 'UR'
      input_array.action.action_m = input_array.action.action_m - %w(DL)
    end
    if last_action == 'DL'
      input_array.action.action_m = input_array.action.action_m - %w(UR)
    end
    if last_action == 'DR'
      input_array.action.action_m = input_array.action.action_m - %w(UL)
    end
    input_array
  end

  # 任兩元素交換位置
  def change_action(input_array, input_action, index_i, index_j)
    input_array_temp = Marshal.load(Marshal.dump(input_array))
    index_i_temp = Marshal.load(Marshal.dump(index_i))
    index_j_temp = Marshal.load(Marshal.dump(index_j))
    if input_action == 'U'
      input_array_temp[index_i][index_j], input_array_temp[index_i][index_j - 1] = input_array_temp[index_i][index_j - 1], input_array_temp[index_i][index_j]
      index_i_temp, index_j_temp = index_i_temp, index_j_temp - 1
    elsif input_action == 'D'
      input_array_temp[index_i][index_j], input_array_temp[index_i][index_j + 1] = input_array_temp[index_i][index_j + 1], input_array_temp[index_i][index_j]
      index_i_temp, index_j_temp = index_i_temp, index_j_temp + 1
    elsif input_action == 'L'
      input_array_temp[index_i][index_j], input_array_temp[index_i - 1][index_j] = input_array_temp[index_i - 1][index_j], input_array_temp[index_i][index_j]
      index_i_temp, index_j_temp = index_i_temp - 1, index_j_temp
    elsif input_action == 'R'
      input_array_temp[index_i][index_j], input_array_temp[index_i + 1][index_j] = input_array_temp[index_i + 1][index_j], input_array_temp[index_i][index_j]
      index_i_temp, index_j_temp = index_i_temp + 1, index_j_temp
    elsif input_action == 'UL'
      input_array_temp[index_i][index_j], input_array_temp[index_i - 1][index_j - 1] = input_array_temp[index_i - 1][index_j - 1], input_array_temp[index_i][index_j]
      index_i_temp, index_j_temp = index_i_temp - 1, index_j_temp - 1
    elsif input_action == 'UR'
      input_array_temp[index_i][index_j], input_array_temp[index_i + 1][index_j - 1] = input_array_temp[index_i + 1][index_j - 1], input_array_temp[index_i][index_j]
      index_i_temp, index_j_temp = index_i_temp + 1, index_j_temp - 1
    elsif input_action == 'DL'
      input_array_temp[index_i][index_j], input_array_temp[index_i - 1][index_j + 1] = input_array_temp[index_i - 1][index_j + 1], input_array_temp[index_i][index_j]
      index_i_temp, index_j_temp = index_i_temp - 1, index_j_temp + 1
    elsif input_action == 'DR'
      input_array_temp[index_i][index_j], input_array_temp[index_i + 1][index_j + 1] = input_array_temp[index_i + 1][index_j + 1], input_array_temp[index_i][index_j]
      index_i_temp, index_j_temp = index_i_temp + 1, index_j_temp + 1
    end
    return input_array_temp, index_i_temp, index_j_temp
  end

  def rank_add(array_m_init)
    rank = 0
    array_m = Marshal.load(Marshal.dump(array_m_init))
    array_m.each_with_index do |x_item, i|
      x_item.each_with_index do |item, j|
        if i != 0 && i != array_m.size - 1
          if item == array_m[i - 1][j] && item == array_m[i + 1][j]
            rank += 1
            array_m[i - 1][j] = rand(0)
            array_m[i][j] = rand(0)
            array_m[i + 1][j] = rand(0)
          end
        end
        if j != 0 && j != array_m[0].size - 1
          if item == array_m[i][j - 1] && item == array_m[i][j + 1]
            rank += 1
            array_m[i][j - 1] = rand(0)
            array_m[i][j] = rand(0)
            array_m[i][j + 1] = rand(0)
          end
        end
      end
    end
    rank
  end

  # 生成後續計算之初始物件
  # 矩陣元素之數量 == init_array.size
  def make_init_array
    times_index = 0
    @init_array.each_with_index do |x_item, i|
      x_item.each_with_index do |_item, j|
        output_data = OutputData.new
        output_data.init_xy[0] = i
        output_data.init_xy[1] = j
        output_data.final_xy[0] = i
        output_data.final_xy[1] = j
        output_data.final_array = Marshal.load(Marshal.dump(@init_array))
        @am_n[times_index] = output_data
        times_index += 1
      end
    end
    Marshal.load(Marshal.dump(@am_n))
  end

  # 主程式method
  def run_case(action_times, combo_times, am_n = @am_n, oblique = 'on')
    am_n_add_one = {}
    times = 1
    while times <= action_times
    # 動作迴圈
      times_index = 0
      am_n.each do |_array_key, array_value|
      # 所有元素進行動作確認（BC確認(bc_check)、上一動作確認(up_move_check)）
        am1 = InitData.new(array_value.final_array, oblique)
        am1 = bc_check(am1, array_value.final_xy[0], array_value.final_xy[1])
        am1 = up_move_check(am1, array_value.action[-1])

        am1.action.action_m.each do |action_item|
        # 對該元素可行之動作進行計算
          array_value_clone = Marshal.load(Marshal.dump(array_value))
          array_value_clone.action << action_item
          array_value_clone.final_array,
          array_value_clone.final_xy[0],
          array_value_clone.final_xy[1] = change_action(am1.init_data_m, action_item, array_value.final_xy[0], array_value.final_xy[1])
          array_value_clone.rank = rank_add(array_value_clone.final_array)
          # if array_value_clone.rank >= times - action_times + combo_times
          if array_value_clone.rank >= combo_times
            am_n_add_one[times_index] = array_value_clone
          end
          times_index += 1
        end
      end
      times += 1
      am_n = am_n.clear
      am_n = Marshal.load(Marshal.dump(am_n_add_one))
      am_n_add_one = am_n_add_one.clear
    end
    @am_n = @am_n.clear
    @am_n = Marshal.load(Marshal.dump(am_n))
    am_n
  end
end

class FinalRun
  def initialize(input_array, no_rank_times, rank_times, oblique)
    @input_array = input_array
    @no_rank_times = no_rank_times
    @rank_times = rank_times
    @oblique = oblique
  end

  def run_case
    test_case = MainRun.new(@input_array)
    am_n = test_case.make_init_array
    @no_rank_times.times do
      am_n = test_case.run_case(1, 0, am_n, @oblique)
    end
    i = 0
    @rank_times.times do |j|
      if test_case.run_case(1, i + 1, Marshal.load(Marshal.dump(am_n))).size == 0
        am_n = test_case.run_case(1, i, am_n, @oblique)
        print(j + 1, " - \n")
      else
        am_n = test_case.run_case(1, i + 1, am_n, @oblique)
        i += 1
        print(j + 1, ' * ', i, "\n")
      end
    end
    am_n
  end
end

def show_hash(am_n)
  am_n.each do |array_key, array_value|
    print(array_key.inspect)
    print('>>')
    print(array_value.inspect)
    print("\n")
  end
end

in_put_array = [[5, 2, 3, 5, 5], [4, 3, 1, 6, 2], [3, 2, 6, 2, 5],
                [6, 5, 4, 1, 1], [3, 2, 6, 6, 4], [4, 4, 1, 5, 3]]
# in_put_array = [[6, 5, 5, 2, 6], [5, 2, 2, 4, 5], [6, 3, 1, 6, 6],
#                 [4, 5, 3, 6, 6], [6, 1, 5, 3, 2], [1, 2, 6, 3, 3]]
no_rank_times = 5
rank_times = 12
oblique = 'off'

auto_run = FinalRun.new(in_put_array, no_rank_times, rank_times, oblique)
# FinalRun.new(輸入矩陣=[[5]*6],無消次數=int,有消次數=int,是否斜轉="on"or"off")
am_n = auto_run.run_case
show_hash(am_n)
