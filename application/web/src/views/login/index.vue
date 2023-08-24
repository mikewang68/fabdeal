<template>
  <div class="login-container">
    <el-form ref="loginForm" class="login-form" auto-complete="on" label-position="left" :rules="loginRules" :model="loginForm">

      <div class="title-container">
        <h3 class="title">基于区块链的商品交易溯源系统</h3>
      </div>
      <el-select v-model="value1" placeholder="请选择用户角色" style="width:70%;margin-left: 70px;" class="login-select" @change="selectGet">
        <el-option
          v-for="item in accountList"
          :key="item.accountId"
          :label="item.userName"
          :value="item.accountId"
        >
          <span style="float: left">{{ item.userName }}</span>
          <span style="float: right; color: #8492a6; font-size: 13px">{{ item.accountId }}</span>
        </el-option>
      </el-select>

  <div class="randomcodeuse" style="width:70%;margin-bottom:20px;" >
		<!-- <el-form class="login-form" status-icon :rules="loginRules" ref="loginForm" :model="loginForm" label-width="0" style="width:70%;margin-bottom:30px;"> -->
			<!-- 随机验证码 输入框 -->
			<el-form-item prop="verifycode" class="input-v">
				<el-input v-model="loginForm.verifycode" placeholder="请输入验证码" class="identifyinput" style="width:70%;margin-bottom:5px;"></el-input>
			</el-form-item>
			<!-- 随机验证码 -->
			<el-form-item>
				<div class="identifybox">
					<div @click="refreshCode">
						<s-identify :identifyCode="identifyCode"></s-identify>
					</div>
					<!-- 刷新验证码 -->
					<el-button @click="refreshCode" type='text' class="textbtn">看不清，换一张</el-button>
				</div>
			</el-form-item>
		<!-- </el-form> -->
	</div>

      <el-button :loading="loading" type="primary" style="width:70%;margin-left: 70px;margin-top: -600px;" @click.native.prevent="handleLogin" round>立即进入</el-button>

      <div class="tips">
        <span style="margin-right:10px;margin-left: 70px;">tips: 选择不同用户角色模拟交易</span>
      </div>
      

    </el-form>
  </div>
</template>

<script>
import { queryAccountList } from '@/api/account'
import SIdentify from '@/components/RandomCode.vue'


export default {
  name: 'Login',
  // name: 'userlogin',
  data() {
    
    // 自定义验证规则：验证码验证规则
			const validateVerifycode = (rule, value, callback) => {
				if (value === '') {
          // this.yzm == 0,
          callback(new Error('请输入验证码'))
				} else if (value !== this.identifyCode) {
          // this.yzm == 0,
					console.log('validateVerifycode:', value)
          
          this.yzm = value,
          console.log('yzm:', this.yzm)
					callback(new Error('验证码不正确'))
				} else {
          // this.yzm == 1,
          this.yzm = value,
					callback()
				}
			}

    return {
      loading: false,
      redirect: undefined,
      accountList: [],
      value1: '',
      yzm: '',
      //
      loginForm: {
					verifycode: ''
				},
				identifyCodes: '1234567890',
				identifyCode: '',
				loginRules: { 
					verifycode: [
						{ required: true, trigger: 'blur', validator: validateVerifycode },
					]
				}
    }
  },

  //
  components: {
			// 注册绘制随机验证码的组件
			SIdentify
		},
  watch: {
    $route: {
      handler: function(route) {
        this.redirect = route.query && route.query.redirect
      },
      immediate: true
    }
  },
  created() {
    queryAccountList().then(response => {
      if (response !== null) {
        this.accountList = response
      }
    })
  },
  methods: {
    handleLogin() {
      // console.log(verifycode)
      // console.log(yzm)
      // debugger
      console.log(this.identifyCode) 
      console.log(this.yzm)
      if ( this.identifyCode != this.yzm || this.identifyCode ==''){
        // debugger
        this.$message.error('验证码不正确!')
        
      }else{
        if (this.value1) {
        this.loading = true
        this.$store.dispatch('account/login', this.value).then(() => {
          this.$router.push({ path: this.redirect || '/' })
          this.loading = false
          this.$message({
          message: '登陆成功！',
          type: 'success'
        });
        }).catch(() => {
          this.loading = false
        })
      } else {
        this.$message('请选择用户角色')
      }
      }
      
    },
    selectGet(accountId) {
      this.value = accountId
    },
    // 生成随机数
			randomNum(min, max) {
				return Math.floor(Math.random() * (max - min) + min)
			},
			// 切换验证码
			refreshCode() {
				this.identifyCode = ''
				this.makeCode(this.identifyCodes, 4)
			},
			// 生成四位随机验证码
			makeCode(_o, l) {
				for (let i = 0; i < l; i++) {
					this.identifyCode += this.identifyCodes[this.randomNum(0, this.identifyCodes.length)]
				}
				console.log(this.identifyCode)
			}
  }
}
</script>

<style lang="scss" scoped>
$bg:#3d509d;
$dark_gray:#889aa4;
$light_gray:#eee;
.input-v{
  position: relative;
  top: 10%;
}
//
.randomcodeuse{
		width: 60%;
		margin: auto;
		display: flex;
		align-items: center;
	}
	.identifybox {
		display: flex;
		justify-content: space-between;
		margin-top: 7px;
	}
	.iconstyle {
		color: #409EFF;
	}
.login-container {
  min-height: 100%;
  width: 100%;
  background-color: $bg;
  overflow: hidden;

  .login-form {
    position: relative;
    width: 520px;
    max-width: 100%;
    padding: 160px 35px 0;
    margin: 0 auto;
    overflow: hidden;
  }
  .login-select{
   padding: 20px 0px 30px 0px;
   min-height: 100%;
   width: 100%;
   background-color: $bg;
   overflow: hidden;
   text-align: center;
  }
  .tips {
    font-size: 14px;
    color: #fff;
    margin-bottom: 10px;

    span {
      &:first-of-type {
        margin-right: 16px;
      }
    }
  }

  .svg-container {
    padding: 6px 5px 6px 15px;
    color: $dark_gray;
    vertical-align: middle;
    width: 30px;
    display: inline-block;
  }

  .title-container {
    position: relative;

    .title {
      font-size: 26px;
      color: $light_gray;
      margin: 0px auto 40px auto;
      text-align: center;
      font-weight: bold;
    }
  }

  .show-pwd {
    position: absolute;
    right: 10px;
    top: 7px;
    font-size: 16px;
    color: $dark_gray;
    cursor: pointer;
    user-select: none;
  }
}
</style>
