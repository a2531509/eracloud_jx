<%--
  Created by IntelliJ IDEA.
  User: yangning
  Date: 2017-09-15
  Time: 13:31
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
    var $gridview;
    $(function(){
        $.autoComplete({
            id:"certNo",
            text:"cert_no",
            value:"name",
            table:"base_personal",
            keyColumn:"cert_no",
            to:10
        },"name");
        $.autoComplete({
            id:"name",
            text:"name",
            value:"cert_no",
            table:"base_personal",
            keyColumn:"name",
            minLength:1,
            to:10
        },"certNo");
        $gridview = createDataGrid({
            id:"dgview",
            url:"recharge/rechargeAction!toQueryBatchRechargeData.action?dealNo=${param.dealNo}",
            border:false,
            fit:true,
            singleSelect:true,
            scrollbarSize:0,
            pageSize:100,
            toolbar:"#tbview",
            fitColumns:true,
            pageList:[50,100,200,300,500],
            columns:[[
                {field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.05)},
                {field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
                {field:"ACCKIND",title:"账户类型",sortable:true,width:parseInt($(this).width() * 0.06)},
                {field:"AMT",title:"金额",sortable:true,width:parseInt($(this).width() * 0.06)},
                {field:"STATESTR",title:"状态",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.04)},
                {field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.12)},
                {field:"BRCHNAME",title:"网点名称",sortable:true,width:parseInt($(this).width() * 0.1)},
                {field:"USERNAME",title:"柜员名称",sortable:true,width:parseInt($(this).width() * 0.06)},
                {field:"RECHARGETIME",title:"充值时间",sortable:true,width:parseInt($(this).width() * 0.12)},
                {field:"LINE_NUM",title:"行号",sortable:true,width:parseInt($(this).width() * 0.03)},
                {field:"NOTE",title:"备注",sortable:true}
            ]]
        });
        toQueryDetailsList();
    });
    function toQueryDetailsList(){
        var params = getformdata("viewSearchConts");
        params["queryType"] = "0";
        params["rec.customerName"] = $("#name").val();
        params["rec.certNo"] = $("#certNo").val();
        $gridview.datagrid("load",params);
    }
</script>
<n:layout>
	<n:center cssStyle="border:none">
		<div id="tbview">
			<form id="viewSearchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft" style="width:10%;">证件号码：</td>
						<td class="tableright" style="width:20%;"><input id="certNo" name="bp.certNo" type="text" class="textinput" maxlength="18"/></td>
						<td class="tableleft" style="width:10%;">姓名：</td>
						<td class="tableright" style="width:20%;"><input id="name" name="bp.name" type="text" class="textinput" maxlength="15"/></td>
						<td class="tableright" colspan="2">
							<a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="toQueryDetailsList()">查询</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id="dgview"></table>
	</n:center>
</n:layout>