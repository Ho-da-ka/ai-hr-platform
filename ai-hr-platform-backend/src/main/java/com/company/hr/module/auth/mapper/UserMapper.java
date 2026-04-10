package com.company.hr.module.auth.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.company.hr.module.auth.entity.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper extends BaseMapper<User> {
}
