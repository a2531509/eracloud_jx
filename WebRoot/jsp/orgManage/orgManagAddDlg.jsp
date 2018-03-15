<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	$(function() {
		$("#bankId").combobox({
			width:174,
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=BANKID",
			valueField:'codeValue',    
		    textField:'codeName',
		    onSelect:function(node){
		 		$("#certType").val(node.text);
		 	}
		});
		$("#form").form({
			url :"sysOrgan/sysOrganAction!persistenceSysOrgan.action",
			onSubmit : function() {
				parent.$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				var isValid = $(this).form('validate');
				if (!isValid) {
					parent.$.messager.progress('close');
				}
				return isValid;
			},
			success : function(result) {
				parent.$.messager.progress('close');
				result = $.parseJSON(result);
				if (result.status) {
					parent.reload;
					parent.$.modalDialog.openner.datagrid('reload');//之所以能在这里调用到parent.$.modalDialog.openner_datagrid这个对象，是因为role.jsp页面预定义好了
					parent.$.modalDialog.handler.dialog('close');
					parent.$.messager.show({
						title : result.title,
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
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/> 机构编辑</legend>
				<input name="clientId" id="clientId"  type="hidden"/>
				<input name="orgState" id="orgState"  type="hidden"/>
				 <table>
					 <tr>
					 	<th>机构编码</th>
						<td><input name="orgId" id="orgId" type="text"  class="textinput easyui-validatebox" data-options="required:true"  maxlength="4" onkeypress = 'return /^\d$/.test(String.fromCharCode(event.keyCode||event.keycode||event.which))'
								oninput= 'this.value = this.value.replace(/\D+/g, "")'
								onpropertychange='if(!/\D+/.test(this.value)){return;};this.value=this.value.replace(/\D+/g, "")'
								onblur = 'this.value = this.value.replace(/\D+/g, "")'/>
						</td>
					    <th>机构名称</th>
						<td><input name="orgName" id="orgName" placeholder="请输入机构名称" class="textinput easyui-validatebox" type="text" data-options="required:true"/></td>
					 </tr>
					 <tr>
					    <th>机构类型</th>
						<td><select id="orgType" name="orgType" class="easyui-combobox easyui-validatebox"  style="width:174px;"  validType="selectValueRequired['#orgType']" >
															<option value="">请选择</option>
															<option value="01">发卡机构</option>
															<option value="02">清算机构</option>
															<option value="03">收单机构</option>
															<option value="04">机具投资方</option>
															<option value="05">银行</option>
															<option value="06">银联</option>
														</select></td>
						<th>机构级别</th>
						<td><select id="orgClass" class="easyui-combobox easyui-validatebox" name="orgClass" style="width:174px;"  validType="selectValueRequired['#orgClass']"  >
															<option value="1">一级</option>
															<!-- <option value="">请选择</option>
															<option value="2">二级</option>
															<option value="3">三级</option> -->
														</select>
						</td>
					 </tr>
					  <tr>
					    <th>上层机构</th>
						<td><input id="pid" name="pid" type="text" class="textinput easyui-validatebox" readonly="readonly"/></td>
						<th>简称</th>
						<td><input name="orgCode" id="orgCode" type="text" class="textinput easyui-validatebox" data-options="required:true"/></td>
					 </tr>
					  <tr>
					    <th>开户银行</th>
						<td><input id="bankId" name="bankId" type="text" class="textinput easyui-validatebox"  validType="selectValueRequired['bankId']"/></td>
						<th>银行账号</th>
						<td><input id=accNo name="accNo" type="text" class="textinput easyui-validatebox" data-options="required:true" maxlength="20" onkeypress = 'return /^\d$/.test(String.fromCharCode(event.keyCode||event.keycode||event.which))'
								oninput= 'this.value = this.value.replace(/\D+/g, "")'
								onpropertychange='if(!/\D+/.test(this.value)){return;};this.value=this.value.replace(/\D+/g, "")'
								onblur = 'this.value = this.value.replace(/\D+/g, "")'/></td>
					 </tr>
					 <tr>
						<th>联系人</th>
						<td><input id="contact" name="contact" type="text" class="textinput easyui-validatebox"/></td>
						<th>email</th>
						<td><input id=email name="email" type="text" class="textinput" validtype="email"/></td>
					 </tr>
					 <tr>
					    <th>电话</th>
						<td><input id="tel" name="tel" type="text" class="textinput easyui-validatebox" validtype="mobile"/></td>
						<th>传真</th>
						<td><input id=fax name="fax" type="text" class="textinput easyui-validatebox" validtype="phone"/></td>
					 </tr>
					 <tr>
						<th>描述</th>
						<td colspan="3"><textarea class="textinput" name="note"  style="width: 420px;height: 100px;"></textarea></td>
					</tr>
				 </table>
			</fieldset>
		</form>
	</div>
</div>