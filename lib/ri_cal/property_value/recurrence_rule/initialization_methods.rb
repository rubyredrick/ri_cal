module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue
      module InitializationMethods # :nodoc:
        def initialize(value_hash) # :nodoc:
          super
          initialize_from_hash(value_hash) unless value_hash[:value]
        end

        def initialize_from_hash(value_hash) # :nodoc:
          self.freq = value_hash[:freq]
          self.wkst = value_hash[:wkst]
          set_count(value_hash[:count])
          set_until(value_hash[:until])
          self.interval = value_hash[:interval]
          set_by_lists(value_hash)
        end

        def add_part_to_hash(hash, part) # :nodoc:
          part_name, value = part.split("=")
          puts "part=#{part.inspect}" unless part_name
          attribute = part_name.downcase.to_sym
          errors << "Repeated rule part #{attribute} last occurrence was used" if hash[attribute]
          case attribute
          when :freq, :wkst
          when :until
            value = PropertyValue.date_or_date_time(:value => value)
          when :interval, :count
            value = value.to_i
          when :bysecond, :byminute, :byhour, :bymonthday, :byyearday, :byweekno, :bymonth, :bysetpos
            value = value.split(",").map {|int| int.to_i} 
          when :byday
            value = value.split(",")
          else
            errors << "Invalid rule part #{part}"
          end
          hash[attribute] = value
          hash
        end

        private

        def by_list
          @by_list ||= {}
        end

        def calc_by_day_scope(by_lists_hash)
          case freq
          when "YEARLY"
            scope = :yearly
          when "MONTHLY"
            scope = :monthly
          when "WEEKLY"
            scope = :weekly
          else
            scope = :daily
          end
          scope = :monthly if scope != :weekly && by_lists_hash[:bymonth]
          rputs "@by_day_scope is #{scope.inspect}"
          @by_day_scope = scope
        end

        def compute_resets
          @yearly_resets = {}
          @monthly_resets = {}
          @daily_resets = {}
          @hourly_resets = {}
          @minutely_resets = {}
          if by_list[:bysecond]
            [@yearly_resets, @monthly_resets, @daily_resets, @hourly_resets, @minutely_resets].each  do |reset|
              reset[:second] = 0
            end
          end
          if by_list[:byminute]
            [@yearly_resets, @monthly_resets, @daily_resets, @hourly_resets].each  do |reset|
              reset[:minute] = 0
            end
          end
          if by_list[:byhour]
            [@yearly_resets, @monthly_resets, @daily_resets].each  do |reset|
              reset[:minute] = 0
            end
          end
          if by_list[:byday]
            @yearly_resets[:day] = 1
            @monthly_resets[:day] = 1 if @by_day_scope == :monthly
          end
          if by_list[:bymonth]
            @yearly_resets[:month] = 1
            @monthly_resets[:enumerate] = true
          end
          if by_list[:bymonthday]
            [@yearly_resets, @monthly_resets].each  do |reset|
              reset[:day] = 1
            end
          end
          if by_list[:byyearday] || by_list[:byweekno]
            @yearly_resets[:month] = 1
            @yearly_resets[:day] = 1
          end

          @yearly_resets = nil if @yearly_resets.empty?
          @monthly_resets = nil if @monthly_resets.empty?
          @daily_resets = nil if @daily_resets.empty?
          @hourly_resets = nil if @hourly_resets.empty? 
          @minutely_resets = nil if @minutely_resets.empty?
        end
        
        def clear_caches
          @first_from_bymonth =
          nil
        end

        def set_by_lists(value_hash)
          [:bysecond,
            :byminute,
            :byhour,
            :bymonth,
            :bysetpos
            ].each do |which|
              if val = value_hash[which]
                by_list[which] = [val].flatten.sort
              end
            end
            if val = value_hash[:byday]
              by_list[:byday] = [val].flatten.map {|day| RecurringDay.new(day, self, calc_by_day_scope(value_hash))}
            end
            if val = value_hash[:bymonthday]
              by_list[:bymonthday] = [val].flatten.map {|md| RecurringMonthDay.new(md)}
            end
            if val = value_hash[:byyearday]
              by_list[:byyearday] = [val].flatten.map {|yd| RecurringYearDay.new(yd)}
            end
            if val = value_hash[:byweekno]
              by_list[:byweekno] = [val].flatten.map {|wkno| RecurringNumberedWeek.new(wkno, self)}
            end
            compute_resets
            clear_caches
          end
        end
      end
    end
  end