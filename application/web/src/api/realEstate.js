import request from '@/utils/request'

// 新建车辆(管理员)
export function createRealEstate(data) {
  return request({
    url: '/createRealEstate',
    method: 'post',
    data
  })
}

// 获取商品信息(空json{}可以查询所有，指定proprietor可以查询指定客户名下车辆)
export function queryRealEstateList(data) {
  return request({
    url: '/queryRealEstateList',
    method: 'post',
    data
  })
}

 
//数据管理增加
export function eventAdd(obj) {
    return request({
        url: '/api/add',
        method: 'post',
        data: obj
    })
}
 
//数据删除,多选删除id逗号分隔
export function eventDel(obj) {
    return request({
        url: '/api/delete',
        method: 'get',
        params: obj
    })
}
 
//导入
export function eventImport(obj) {
    return request({
        url: '/api/import',
        method: 'post',
        data: obj
    })
}
 
//数据分页
export function eventPage(obj) {
    return request({
        url: '/api/page',
        method: 'post',
        data: obj
    })
}
 
//数据修改
export function eventUpdate(obj) {
    return request({
        url: '/api/update',
        method: 'post',
        data: obj
    })
}