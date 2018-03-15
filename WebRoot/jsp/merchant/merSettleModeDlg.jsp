<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix ="s" uri="/struts-tags"%>
<script type="text/javascript">
	function setValue(vTxt) {
	    $('#merchantId').combobox('setValue', vTxt);
	 }
	function checkEndTime(){  
	    var startTime=$("#validDate").val();  
	    var start=new Date(startTime.replace("-", "/").replace("-", "/"));  
	    var endTime=timeStamp2String(new Date());  
	    var end=new Date(endTime.replace("-", "/").replace("-", "/"));  
	    alert(start +";" + end);
	    if(start<=end){  
	        return false;  
	    }  
	    return true;  
	}  
	
	function timeStamp2String(time){
		var datetime = new Date();     
		datetime.setTime(time);     
		var year = datetime.getFullYear();     
		var month = datetime.getMonth() + 1 < 10 ? "0" + (datetime.getMonth() + 1) : datetime.getMonth() + 1;     
		var date = datetime.getDate() < 10 ? "0" + datetime.getDate() : datetime.getDate();     
		return year + "-" + month + "-" + date; 
	} 
	$(function() {
		 $('#merchantId').combobox({
	      url:"merchantRegister/merchantRegisterAction!findALLMerchant.action",
          valueField: 'merchantId', 
          textField: 'merchantName',
          //注册事件
          onChange: function (newValue, oldValue) {
              if (newValue != null) {
                  var thisKey = encodeURIComponent($('#merchantId').combobox('getText')); //搜索词
                  var urlStr = "merchantRegister/merchantRegisterAction!getBizName.action?objStr=" + thisKey;
                  var v = $("#merchantId").combobox("reload", urlStr);
              }
          },
          
      });
		 
		 
		 $("#stlMode").combobox({
				width:174,
				url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=STL_MODE",
				valueField:'codeValue', 
				editable:false, //不可编辑状态
			    textField:'codeName',
			    loadFilter:function(data){
					if(data.status != "0"){
					}
					return data.rows;
				},
			    onSelect:function(node){
			 		$("#stlMode").val(node.text);
			 	}
			});
			$("#stlWay").combobox({
				width:174,
				url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=STL_WAY",
				valueField:'codeValue', 
				editable:false, //不可编辑状态
			    textField:'codeName',
			    loadFilter:function(data){
					if(data.status != "0"){
					}
					return data.rows;
				},
			    onSelect:function(node){
			 		$("#stlWay").val(node.text);
			 		if(Number(node.codeValue)==2){
			 			$("#styWay1_lmt_th").css("display","table-cell");
			 			$("#styWay1_lmt_td").css("display","table-cell");
			 			$("#styWay1_cicrl_th").css("display","none");
			 			$("#styWay1_cicrl_td").css("display","none");
			 		}else{
			 			$("#styWay1_lmt_th").css("display","none");
			 			$("#styWay1_lmt_td").css("display","none");
			 			$("#styWay1_cicrl_th").css("display","table-cell");
			 			$("#styWay1_cicrl_td").css("display","table-cell");
			 		}
			 	}
			});
			$("#stlWayRet").combobox({
				width:174,
				url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=STL_WAY",
				valueField:'codeValue', 
				editable:false, //不可编辑状态
			    textField:'codeName',
			    loadFilter:function(data){
					if(data.status != "0"){
					}
					return data.rows;
				},
			    onSelect:function(node){
			 		$("#stlWayRet").val(node.text);
			 		if(Number(node.codeValue)==2){
			 			$("#styWay2_lmt_th").css("display","table-cell");
			 			$("#styWay2_lmt_td").css("display","table-cell");
			 			$("#styWay2_cicrl_th").css("display","none");
			 			$("#styWay2_cicrl_td").css("display","none");
			 		}else{
			 			$("#styWay2_lmt_th").css("display","none");
			 			$("#styWay2_lmt_td").css("display","none");
			 			$("#styWay2_cicrl_th").css("display","table-cell");
			 			$("#styWay2_cicrl_td").css("display","table-cell");
			 		}
			 	}
			});
			$("#stlWayFee").combobox({
				width:174,
				url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=STL_WAY",
				valueField:'codeValue', 
				editable:false, //不可编辑状态
			    textField:'codeName',
			    loadFilter:function(data){
					if(data.status != "0"){
					}
					return data.rows;
				},
			    onSelect:function(node){
			 		$("#stlWayFee").val(node.text);
			 		if(Number(node.codeValue)==2){
			 			$("#styWay3_lmt_th").css("display","table-cell");
			 			$("#styWay3_lmt_td").css("display","table-cell");
			 			$("#styWay3_cicrl_th").css("display","none");
			 			$("#styWay3_cicrl_td").css("display","none");
			 		}else{
			 			$("#styWay3_lmt_th").css("display","none");
			 			$("#styWay3_lmt_td").css("display","none");
			 			$("#styWay3_cicrl_th").css("display","table-cell");
			 			$("#styWay3_cicrl_td").css("display","table-cell");
			 		}
			 	}
			});
		
		
		$("#form").form({
			url :"merchantRegister/merchantRegisterAction!saveMerSettleMode.action",
			data: $('#form').serialize(),
			onSubmit : function() {
				/* if(!checkEndTime()){
					parent.$.messager.show({
						title :'系统消息',
						msg : '您输入的生效日期不能在今天及今天之前！',
						timeout : 1000 * 3
	    			});
					return false;
				} */
				if($("#stlMode").combobox('getValue')==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入结算模式！',
						timeout : 1000 * 3
	    			});
					return false;
				}
				if($("#stlWay").combobox('getValue')==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入结算方式！',
						timeout : 1000 * 3
	    			});
					return false;
				}else{
					if($("#stlWay").combobox('getValue')=='2'){
						if($("#stlLim").val()==''){
							parent.$.messager.show({
								title :'系统消息',
								msg : '请输入结算限额参数！',
								timeout : 1000 * 3
			    			});
							return false;
						}
					}else{
						if($("#stlDays").val()==''){
							parent.$.messager.show({
								title :'系统消息',
								msg : '请输入结算周期！',
								timeout : 1000 * 3
			    			});
							return false;
						}
					}
				}
				
				if($("#stlWayRet").combobox('getValue')==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入退货结算方式！',
						timeout : 1000 * 3
	    			});
					return false;
				}else{
					if($("#stlWayRet").combobox('getValue')=='2'){
						if($("#stlLimRet").val()==''){
							parent.$.messager.show({
								title :'系统消息',
								msg : '请输入退货结算限额参数！',
								timeout : 1000 * 3
			    			});
							return false;
						}
					}else{
						if($("#stlDaysRet").val()==''){
							parent.$.messager.show({
								title :'系统消息',
								msg : '请输入退货结算周期！',
								timeout : 1000 * 3
			    			});
							return false;
						}
					}
				}
				
				if($("#stlWayFee").combobox('getValue')==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入服务费结算方式！',
						timeout : 1000 * 3
	    			});
					return false;
				}else{
					if($("#stlWayFee").combobox('getValue')=='2'){
						if($("#stlLimFee").val()==''){
							parent.$.messager.show({
								title :'系统消息',
								msg : '请输入服务费结算限额参数！',
								timeout : 1000 * 3
			    			});
							return false;
						}
					}else{
						if($("#stlDaysFee").val()==''){
							parent.$.messager.show({
								title :'系统消息',
								msg : '请输入服务费结算周期！',
								timeout : 1000 * 3
			    			});
							return false;
						}
					}
				}
				if($("#merchantId").combobox('getValue')==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '商户名称不能空！',
						timeout : 1000 * 3
	    			});
					return false;
				}
				parent.$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				var isValid = $(this).form('validate');
				if (!isValid) {
					parent.$.messager.progress('close');
				}
				return isValid;
				//验证输入框的值
				
			},
			success:function(result) {
				parent.$.messager.progress('close');
				result = $.parseJSON(result);
				if (result.status) {
					parent.reload;
					parent.$.modalDialog.openner.datagrid('reload',{
						queryType:'0'});
					parent.$.modalDialog.handler.dialog('close');
					parent.$.messager.show({
						title :  result.title,
						msg : result.message,
						timeout : 1000 * 2
					});
				}else{
					parent.$.messager.show({
						title :  result.title,
						msg : result.message,
						timeout : 1000 * 2
					});
				}
			}
		});
		
	});
	
</script>
<style>
	.textinput{
		height: 18px;
		width: 170px;
		line-height: 16px;
	    /*border-radius: 3px 3px 3px 3px;*/
	    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) inset;
	    transition: border 0.2s linear 0s, box-shadow 0.2s linear 0s;
	}
	
	textarea:focus, input[type="text"]:focus{
	    border-color: rgba(82, 168, 236, 0.8);
	    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) inset, 0 0 8px rgba(82, 168, 236, 0.6);
	    outline: 0 none;
		}
		table {
	    background-color: transparent;
	    border-collapse: collapse;
	    border-spacing: 0;
	    max-width: 100%;
	}

	fieldset {
	    border: 0 none;
	    margin: 0;
	    padding: 0;
	}
	legend {
	    -moz-border-bottom-colors: none;
	    -moz-border-left-colors: none;
	    -moz-border-right-colors: none;
	    -moz-border-top-colors: none;
	    border-color: #E5E5E5;
	    border-image: none;
	    border-style: none none solid;
	    border-width: 0 0 1px;
	    color: #999999;
	    line-height: 20px;
	    display: block;
	    margin-bottom: 10px;
	    padding: 0;
	    width: 100%;
	}
	input, textarea {
	    font-weight: normal;
	}
	table ,th,td{
		text-align:left;
		padding: 6px;
	}
</style>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;padding: 10px;">
		<form id="form" method="post">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>商户结算模式信息</legend>
				<input name="typeDeal" id="typeDeal" value="${typeDeal}" type="hidden"/>
				 <table>
				 	  <tr>
						<th>结算周期说明:</th>
						<td colspan ="3">
						<span style="color:red">结算方式为日结，结算周期为1表示：每天产生结算数据；<br/>结算方式为周结，结算周期为1表示：每周的星期一产生结算数据；<br/>结算方式为月结，结算周期为1表示：每月1号产生结算数据，如果想每月最后一天产生结算数据结算周期写32</span>
						</td>
					</tr>
					<tr>
					  <th>商户名称</th>
						<td colspan ="3"><input name="merchantStlMode.id.merchantId" id="merchantId" value="${merchantStlMode.id.merchantId}"  class="textinput easyui-validatebox" type="text" /></td>
					</tr>
					<tr>
					<th>结算模式:</th>
					<td ><input name="merchantStlMode.stlMode" id="stlMode"  value="${merchantStlMode.stlMode}" class="easyui-combobox easyui-validatebox"  data-options="panelHeight: 'auto',editable:false" type="text"  style="width:174px;"/></td>
					<th >生效日期</th>
					<td clospan="3">
						<input name="merchantStlMode.id.validDate" id="validDate" value="${merchantStlMode.id.validDate}" class="easyui-datebox" style="width:174px;" required="required"/>
					</td>
					<tr>
						<th>消费结算方式</th>
						<td><input name="merchantStlMode.stlWay" id="stlWay" value="${merchantStlMode.stlWay}"  class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false" type="text"  style="width:174px;"/>
						</td>
						
						<th id="styWay1_lmt_th">限额参数</th>
						<td id="styWay1_lmt_td"><input name="merchantStlMode.stlLim" id="stlLim"  value="${merchantStlMode.stlLim}" class="textinput easyui-validatebox" type="text" />
						</td>
						<th id="styWay1_cicrl_th" >结算周期</th>
						<td id="styWay1_cicrl_td" ><input name="merchantStlMode.stlDays" id="stlDays"  value="${merchantStlMode.stlDays}" class="textinput easyui-validatebox" type="text" />
						</td>
					</tr>
					<tr>
						<th>退货结算方式</th>
						<td><input name="merchantStlMode.stlWayRet" id="stlWayRet"  value="${merchantStlMode.stlWayRet}" class="easyui-combobox easyui-validatebox"  data-options="panelHeight: 'auto',editable:false" type="text"  style="width:174px;"/>
						</td>
						<th id="styWay2_lmt_th" >限额参数</th>
						<td id="styWay2_lmt_td" ><input name="merchantStlMode.stlLimRet" id="stlLimRet"  value="${merchantStlMode.stlLimRet}" class="textinput easyui-validatebox" type="text" />
						</td>
						<th id="styWay2_cicrl_th" >结算周期</th>
						<td id="styWay2_cicrl_td"><input name="merchantStlMode.stlDaysRet" id="stlDaysRet"   value="${merchantStlMode.stlDaysRet}"  class="textinput easyui-validatebox" type="text" />
						</td>
					</tr>
					
					<tr>
						<th>服务费结算方式</th>
						<td><input name="merchantStlMode.stlWayFee" id="stlWayFee"  class="easyui-combobox easyui-validatebox" value="${merchantStlMode.stlWayFee}" data-options="panelHeight: 'auto',editable:false" type="text"  style="width:174px;"/>
						</td>
						<th id="styWay3_lmt_th">限额参数</th>
						<td id="styWay3_lmt_td"><input name="merchantStlMode.stlLimFee" id="stlLimFee" value="${merchantStlMode.stlLimFee}"  class="textinput easyui-validatebox" type="text" />
						<th id="styWay3_cicrl_th" >结算周期</th>
						<td id="styWay3_cicrl_td"><input name="merchantStlMode.stlDaysFee" id="stlDaysFee"  value="${merchantStlMode.stlDaysFee}"   class="textinput easyui-validatebox" type="text" />
						</td>
					</tr>
				 </table>
			</fieldset>
			</form>
	</div>
</div>
